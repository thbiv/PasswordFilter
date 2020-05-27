Function Install-PassFiltEx {
    <#
    .EXTERNALHELP PasswordFilter-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName
    )
    # Location of the Blacklist master file
    $BlackList = $((GetPasswordFilterSourcePaths).Blacklist)
    # Location of the source DLL file
    $DLL = $((GetPasswordFilterSourcePaths).DLL)
    # Get the hash of the Blacklist master file
    $BlacklistHash = Get-FileHash -Path $BlackList
    # Check if the Blacklist master file is present for copy
    If (Test-Path -Path $Blacklist) {
        # Check if the source DLL file is present for copy
        If (Test-Path -Path $DLL) {
            $Targets = @()
            # If the ServerName parameter is used, set the targets to the value of the parameter.
            # If no parameter is used, programatically find all Domain Controllers.
            If ($ServerName) {
                $Targets += $ServerName
            } Else {
                $Targets += $(GetAllDomainControllers)
            }
            # Loop through each target
            ForEach ($Target in $Targets) {
                # Test if the target is accessible (ping)
                If (Test-Connection -ComputerName $Target -Count 1 -Quiet) {
                    # TargetDir - This is the directory where the DLL file and BlackList file will be copied to.
                    $TargetDir = "\\$Target\c$\windows\system32"
                    # Test if the Blacklist file exists. If it does not exist, copy the file.
                    If (Test-Path -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')) {
                        Write-Verbose "[PasswordFilter][$Target][BlacklistFile] File already exists. Checking hash values"
                        $TestHash = Get-FileHash -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')
                        # If the file exists, test file hashes of the file on the target and the payload. If they match, skip the copy.
                        # If they do not match, continue with the copy
                        If ($($TestHash.Hash) -eq $($BlacklistHash.Hash)) {
                            Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes match"
                            Write-Verbose "[PasswordFilter][$Target][BlacklistFile] File Copy Skipped"
                        } Else {
                            Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes do not match"
                            If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltExBlacklist.txt")) {
                                Copy-Item -Path $BlackList -Destination $TargetDir -ErrorAction Stop
                            }
                        }
                    } Else {
                        If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltExBlacklist.txt")) {
                            Copy-Item -Path $BlackList -Destination $TargetDir -ErrorAction Stop
                        }
                    }
                    # Test if the DLL file exists. If it does not exist, copy the file.
                    # If it exists, check the version. If the version is the same, skip the copy. If they are different, copy the file.
                    If (Test-Path -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltEx.dll')) {
                        Write-Verbose "[PasswordFilter][$Target][DLLFile] File already exists."
                        $DLLVersion = (Get-ItemProperty -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltEx.dll') | Select-Object -ExpandProperty VersionInfo).ProductVersion
                        If ($DLLVersion -eq $((Get-ItemProperty -Path $DLL | Select-Object -ExpandProperty VersionInfo).ProductVersion)) {
                            Write-Verbose "[PasswordFilter][$Target][DLLFile] DLL File is up to date"
                            Write-Verbose "[PasswordFilter][$Target][DLLFile] File Copy Skipped"
                        } Else {
                            Write-Verbose "[PasswordFilter][$Target][DLLFile] DLL file version mismatch"
                            If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltEx.dll")) {
                                Copy-Item -Path $DLL -Destination $TargetDir -ErrorAction Stop
                            }
                        }
                    } Else {
                        If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltEx.dll")) {
                            Copy-Item -Path $DLL -Destination $TargetDir -ErrorAction Stop
                        }
                    }
                    # Enable the Password Filter using the registry.
                    $Subkey = 'SYSTEM\CurrentControlSet\Control\LSA'
                    $Value  = 'Notification Packages'
                    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Target)
                    $Key = $reg.OpenSubKey($Subkey, $True)
                    $Arr = $key.GetValue($Value)
                    If ($Arr -contains "PassFiltEx") {
                        Write-Verbose "PassFltEx filter entry is already present"
                    }
                    Else {
                        If ($PSCmdlet.ShouldProcess("$Target","Add 'PassFltEx' Filter")) {
                            $Arr += 'PassFiltEx'
                            $Key.SetValue($Value, [string[]]$Arr, 'MultiString')
                        }
                    }
                } Else {
                    Write-Warning -Message "[PasswordFilter][$Target] Is Offline"
                }
            }
        }  Else {
            Write-Warning -Message "[PasswordFilter] Cannot Find: $DLL"
        }
    } Else {
        Write-Warning -Message "[PasswordFilter] Cannot Find: $Blacklist"
    }
}
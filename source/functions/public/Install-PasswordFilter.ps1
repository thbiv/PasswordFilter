Function Install-PasswordFilter {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName
    )
    $BlackList = "\\sfhousanp01\it\Security_Team\Password_Filter\PWD-Blacklist\PassFiltExBlacklist.txt"
    $DLL = "\\sfhousanp01\it\Security_Team\Password_Filter\PWD-Blacklist\PassFiltEx.dll"
    $BlacklistHash = Get-FileHash -Path $BlackList
    # Check if the Blacklist file is present for copy
    If (Test-Path -Path $Blacklist) {
        # Check if the DLL file is present for copy
        If (Test-Path -Path $DLL) {
            $Targets = @()
            # If the ServerName parameter is used, set the targets to the value of the parameter.
            # If no parameter is used, programatically find all Domain Controllers.
            If ($ServerName) {
                $Targets += $ServerName
            } Else {
                $Targets += $(Get-AllDomainControllers)
            }
            # Loop through each taget
            ForEach ($Target in $Targets) {
                # Test if the target is accessible (ping)
                If (Test-Connection -ComputerName $Target -Count 1 -Quiet) {
                    $TargetDir = "\\$Target\c$\windows\PWD-Blacklist"
                    $DLLDir = "\\$Target\c$\windows\system32"
                    # If the $TargetDir path does not exist, create it.
                    If(!(Test-Path -Path $TargetDir)){
                        If ($PSCmdlet.ShouldProcess("$Target","Create Directory: $TargetDir")) {
                            New-Item -Force -ItemType directory -Path $TargetDir -ErrorAction Stop
                        }
                    }
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
                    # Test if the DLL file exists. If it does not exist, copy the file. If it exists, skip the copy.
                    If (Test-Path -Path $(Join-Path -Path $DLLDir -ChildPath 'PassFiltEx.dll')) {
                        Write-Verbose "[PasswordFilter][$Target][DLLFile] File already exists."
                        Write-Verbose "[PasswordFilter][$Target][DLLFile] File Copy Skipped"
                    } Else {
                        If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltEx.dll")) {
                            Copy-Item -Path $DLL -Destination $DLLDir -ErrorAction Stop
                        }
                    }
                    # Set the PasswordFilter settings in the registry.
                    If ($PSCmdlet.ShouldProcess("$Target","Add Registry Entries")) {
                        Invoke-Command -ComputerName $Target -ScriptBlock {
                            New-Item -Path HKLM:\Software -Name PassFiltEx
                            New-ItemProperty -Path HKLM:\Software\PassFiltEx -Name BlacklistFileName -Value “c:\windows\PWD-Blacklist\PassFiltExBlacklist.txt”
                            New-ItemProperty -Path HKLM:\Software\PassFiltEx -Name TokenPercentageOfPassword -PropertyType DWord -Value “60”
                            New-ItemProperty -Path HKLM:\Software\PassFiltEx -Name RequireCharClasses -PropertyType DWord -Value “0”
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
                    Write-Warning -Message "[PasswordFilter][$Target] Connection Failed"
                }
            }
        }  Else {
            Write-Warning -Message "[PasswordFilter] Cannot Find: $DLL"
        }
    } Else {
        Write-Warning -Message "[PasswordFilter] Cannot Find: $Blacklist"
    }
}
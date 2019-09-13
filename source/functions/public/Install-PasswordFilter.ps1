Function Install-PasswordFilter {
    <#
    .SYNOPSIS
        Installs the PassFiltEx AD Password Filter onto domain controllers.
    .DESCRIPTION
        To install the PassFiltEx password filter, this command will:
        1. Copy the DLL file of the password filter (PassFiltEx.dll) to: C:\Windows\System32
        2. Copy the Blacklist text file (PassFiltExBlacklist.txt) to: C:\Windows\System32
        3. Modified the Notification Packages registry entry at HKLM:\SYSTEM\CurrentControlSet\Control\LSA to include 'PassFiltEx'
        After all 3 steps are complete. The domain controller will need to be rebooted for the Password Filter to start working.

        Because this command does check to see if the files and registry entry is present already, this can be used to upgrade the password filter as well.
    .PARAMETER ServerName
        Server hostname or list of hostnames
    .EXAMPLE
        PS C:\> .\Install-PasswordFilter.ps1 -ServerName dc01

        This example will install the password filter onto the domain controller named dc01.
    .EXAMPLE
        PS C:\> .\Install-PasswordFilter.ps1 -ServerName dc01,dc02,dc03

        This example will install the password filter on the 3 listed domain controllers, dc01,dc02,dc03.
    .EXAMPLE
        PS C:\> .\Install-PasswordFilter.ps1

        This example will install the password filter on all writable domain controllers in the current domain.
    .INPUTS
        string
    .OUTPUTS
        None
    .LINK
        https://github.com/ryanries/PassFiltEx/releases
    .LINK
        https://github.com/ryanries/PassFiltEx/blob/master/README.md
    .NOTES
        Written by Thomas Barratt
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
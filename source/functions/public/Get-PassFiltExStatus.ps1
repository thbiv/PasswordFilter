Function Get-PassFiltExStatus {
    <#
    .EXTERNALHELP PasswordFilter-help.xml
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName
    )
    # Location of the Blacklist master file
    $SourceBlackListPath = $((GetPasswordFilterSourcePaths).Blacklist)
    # Location of the source DLL file
    $SourceDLLPath = $((GetPasswordFilterSourcePaths).DLL)
    # Check if the Blacklist master file exists
    If (Test-Path -Path $SourceBlackListPath) {
        Write-Verbose "[PasswordFilter] Source Blacklist file exists"
        # Get the file hash for the Blacklist master file
        $SourceBlacklistHash = Get-FileHash -Path $SourceBlackListPath
        $Targets = @()
        # If the ServerName parameter is used, set the targets to the value of the parameter.
        # If no parameter is used, programatically find all Domain Controllers.
        If ($ServerName) {
            Write-Verbose "[PasswordFilter] Using 'ServerName' parameter"
            $Targets += $ServerName
        } Else {
            Write-Verbose "[PasswordFilter] Not using the 'ServerName' parameter. Generating list of all Domain Controllers"
            $Targets += $(GetAllDomainControllers)
        }
        Write-Verbose "[PasswordFilter] Targets: $($Targets -join ',')"
        $Output = @()
        # Loops through all of the writable domain controllers
        ForEach ($Target in $Targets) {
            # Path of where the local blacklist should be
            $BlacklistPath = "\\$Target\c$\windows\System32\PassFiltExBlacklist.txt"
            # Check if the local Blacklist is present. Output True or False
            $BlacklistExists = If (Test-Path -Path $BlacklistPath) {$True} Else {$False}
            If ($BlacklistExists -eq $True) {
                Write-Verbose "[PasswordFilter][$Target] Blacklist file exists"
                $BlacklistHash = (Get-FileHash -Path $BlacklistPath).Hash
                If ($BlacklistHash -eq $($SourceBlacklistHash.Hash)) {
                    Write-Verbose "[PasswordFilter][$Target] Blacklist File Hashes Match"
                    $HashMatches = $True
                } Else {
                    Write-Verbose "[PasswordFilter][$Target] Blacklist File Hashes Do Not Match"
                    Write-Verbose "[PasswordFilter][$Target] Blacklist update required"
                    $HashMatches = $False
                }
            } Else {
                Write-Verbose "[PasswordFilter][$Target] Blacklist File Does Not Exist"
                $BlacklistHash = 'Not Available'
                $HashMatches = $False
            }

            $DLLPath = "\\$Target\c$\windows\system32\PassFiltEx.dll"
            $DLLExists = If (Test-Path -Path $DLLPath) {$True} Else {$False}
            If ($DLLExists -eq $True) {
                Write-Verbose "[PasswordFilter][$Target] DLL File Exists"
                $DLLVersion = (Get-ItemProperty -Path $DLLPath | Select-Object -ExpandProperty VersionInfo).ProductVersion
                If ($DLLVersion -eq $((Get-ItemProperty -Path $SourceDLLPath | Select-Object -ExpandProperty VersionInfo).ProductVersion)) {
                    Write-Verbose "[PasswordFilter][$Target] DLL is up to date"
                    $UpgradeNeeded = $False
                } Else {
                    Write-Verbose "[PasswordFilter][$Target] DLL is out of date"
                    Write-Verbose "[PasswordFilter][$Target] Run the install script on this Domain Controller to update it"
                    $UpgradeNeeded = $True
                }
            } Else {
                Write-Verbose "[PasswordFilter][$Target] DLL File does not eixst"
                Write-Verbose "[PasswordFilter][$Target] The password filter may need to be installed"
                Write-Verbose "[PasswordFilter][$Target] Run the install script on this Domain Controller to install it"
                $DLLVersion = 'Not Available'
                $UpgradeNeeded = $False
            }

            $Subkey = 'SYSTEM\CurrentControlSet\Control\LSA'
            $Value  = 'Notification Packages'
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Target)
            $Key = $reg.OpenSubKey($Subkey, $True)
            $Arr = $key.GetValue($Value)
            If ($Arr -contains "PassFiltEx") {
                Write-Verbose "[PasswordFilter][$Target] Password Filter is enabled in registry"
                $PFEnabled = $True
            } Else {
                Write-Verbose "[PasswordFilter][$Target] Password Filter is not enabled in registry"
                Write-Verbose "[PasswordFilter][$Target] Run the install script on this Domain Controller to enable it"
                $PFEnabled = $False
            }

            $Obj = New-Object -TypeName PasswordFilterStatus -ArgumentList $Target,
                                                                           $BlacklistExists,
                                                                           $HashMatches,
                                                                           $DLLExists,
                                                                           $DLLVersion,
                                                                           $UpgradeNeeded,
                                                                           $PFEnabled
            $Output += $Obj
        }
        Write-Output $Output
    }
}
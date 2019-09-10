Function Get-PasswordFilterStatus {
    <#
    .SYNOPSIS
        Gets Password Filter status from domain controllers
    .DESCRIPTION
        Returns the Password Filter status of domain controllers as a PSObject.
        The PSObject returned contains the following attributes.

        ServerName - The hostname of the server that the object describes.
        BlacklistPath - The UNC path to where the Blacklist file should be on the server.
        BlacklistExists - True is the Blacklist is present. False if it is not.
        BlacklistHash - File Hash of the Blacklist file using SHA256.
        BlacklistCurrent - True is the file hash matches the master file. False if it does not. This means the Blacklist needs to be updated.
        DLLPath - The UNC path to where the DLL file should be on the server.
        DLLVersion - The version number of the DLL file. This is the version of the Password filter itself.
        Enabled - True is it is enabled, False if it is not. This checks the Notification Packages registry setting looking for PassFiltEx to be present.
    .PARAMETER ServerName
        Server hostname or list of hostnames
    .EXAMPLE
        PS C:\> .\Get-PasswordFilterStatus.ps1 -ServerName dc01

        This example will get the Password Filter status for dc01
    .EXAMPLE
        PS C:\> .\Get-PasswordFilterStatus.ps1 -ServerName dc01,dc02,dc03

        This example will get the Password Filter status for the servers dc01, dc02, and dc03
    .EXAMPLE
        PS C:\> .\Get-PasswordFilterStatus.ps1

        This example will get the Password Filter status for all writable domain controllers in the domain.
    .INPUTS
        String
    .OUTPUTS
        PSObject
    .LINK
        https://github.com/ryanries/PassFiltEx/releases
    .LINK
        https://github.com/ryanries/PassFiltEx/blob/master/README.md
    .NOTES
        Written By Thomas Barratt
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName
    )
    # Location of the Blacklist master file
    $SourceBlackListPath = "\\sfhrsfile01\shared\Horsham-IT\Password_Filter\Production\PassFiltExBlacklist.txt"
    # Location of the source DLL file
    $SourceDLLPath = "\\sfhrsfile01\shared\Horsham-IT\Password_Filter\Production\PassFiltEx.dll"
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

            $OutputProps = [ordered]@{
                'ServerName' = $Target
                'BlackListPath' = $BlackListPath
                'BlackListExists' = $BlacklistExists
                'BlackListHash' = $BlacklistHash
                'BlackListCurrent' = $HashMatches
                'DLLPath' = $DLLPath
                'DLLExists' = $DLLExists
                'DLLVersion' = $DLLVersion
                'Enabled' = $PFEnabled
                'UpgradeNeeded' = $UpgradeNeeded
            }
            $Obj = New-Object -TypeName PSObject -Property $OutputProps
            $Output += $Obj
            Write-Output $Output
        }
    }
}
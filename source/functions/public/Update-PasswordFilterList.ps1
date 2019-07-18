Function Update-PasswordFilterList {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string]$ServerName
    )
    $Targets = @()
    If ($ServerName) {
        $Targets += $ServerName
    } Else {
        $Targets += $(Get-AllDomainControllers)
    }
    $TargetDir = "\\$Target\c$\windows\PWD-Blacklist"
    $Blacklist = "\\sfhousanp01\it\Security_Team\Password_Filter\PWD-Blacklist\PassFiltExBlacklist.txt"
    $BlacklistHash = Get-FileHash -Path $Blacklist
    ForEach ($Target in $Targets) {
        If(!(Test-Path -Path $TargetDir)){
            Write-Warning "Directory Does not exist: $TargetDir"
            Write-Warning "PasswordFilter needs to be installed first."
        } Else {
            $TestHash = Get-FileHash -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')
            If ($($TestHash.Hash) -eq $($BlacklistHash.Hash)) {
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes match"
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] File Copy Skipped"
            } Else {
                If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltExBlacklist.txt")) {
                    Try {
                        Copy-Item -Path $Blacklist -Destination $TargetDir -ErrorAction Stop
                    } Catch {
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning $ErrorMessage
                    }
                }
            }

        }
    }
}
Function Update-PassFiltExBlacklist {
    <#
    .EXTERNALHELP PasswordFilter-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName
    )
    $Targets = @()
    If ($ServerName) {
        $Targets += $ServerName
    } Else {
        $Targets += $(GetAllDomainControllers)
    }
    $Blacklist = $((GetPasswordFilterSourcePaths).Blacklist)
    $BlacklistHash = Get-FileHash -Path $Blacklist
    ForEach ($Target in $Targets) {
        $TargetDir = "\\$Target\c$\windows\system32"
        If(!(Test-Path -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt'))){
            Write-Warning "[PasswordFilter][$Target][BlacklistFile] File does not exist: $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')"
            Write-Warning "[PasswordFilter][$Target][BlacklistFile] PasswordFilter may need to be installed first"
        } Else {
            $TestHash = Get-FileHash -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')
            If ($($TestHash.Hash) -eq $($BlacklistHash.Hash)) {
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes match"
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] File Copy Skipped"
            } Else {
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes do not match"
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
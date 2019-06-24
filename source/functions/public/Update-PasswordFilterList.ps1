Function Update-PasswordFilterList {
    [CmdletBinding()]
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
    ForEach ($Target in $Targets) {
        $TargetDir = "\\$Target\c$\windows\PWD-Blacklist"
        $Blacklist = "\\sfhousanp01\it\Security_Team\Password_Filter\PWD-Blacklist\PassFiltExBlacklist.txt"
        If(!(Test-Path -Path $TargetDir)){
            Write-Warning "Directory Does not exist: $TargetDir"
            Write-Warning "PasswordFilter needs to be installed first."
        } Else {

        }
        Try {
            Copy-Item -Path $Blacklist -Destination $TargetDir -ErrorAction Stop
        } Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning $ErrorMessage
        }
    }

}
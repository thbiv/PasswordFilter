Function Compare-PassFiltExBlacklist {
    <#
    .EXTERNALHELP PasswordFilter-help.xml
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName,

        [Parameter(Mandatory=$False)]
        [switch]$IncludeEqual
    )

    $SourceBlackListPath = $((GetPasswordFilterSourcePaths).Blacklist)
    $SourceBlackListContent = Get-Content -Path $SourceBlackListPath
    $Output = @()
    If (Test-Path -Path $SourceBlackListPath) {
        ForEach ($Target in $ServerName) {
            $TargetBlackListPath = "\\$Target\c$\windows\system32\PassFiltExBlacklist.txt"
            If (Test-Path -Path $TargetBlackListPath) {
                $TargetBlackListContent = Get-Content -Path $TargetBlackListPath
                $Props = @{
                    'ReferenceObject' = $SourceBlackListContent
                    'DifferenceObject' = $TargetBlackListContent
                }
                If ($IncludeEqual) {$Props.Add('IncludeEqual',$True)}
                $Results = Compare-Object @Props
                ForEach ($Result in $Results) {
                    If ($Result.SideIndicator -eq '=>') {
                        $Side = 'OnServer'
                    } ElseIf ($Result.SideIndicator -eq '<=') {
                        $Side = 'OnSource'
                    } ElseIf ($Result.SideIndicator -eq '==') {
                        $Side = 'OnBoth'
                    }
                    $Obj = New-Object -TypeName PasswordFilterBlacklistCompare -ArgumentList $Target,
                                                                                             $($Result.InputObject),
                                                                                             $Side
                    $Output += $Obj
                }
            }
        }
        Write-Output $Output
    }
}
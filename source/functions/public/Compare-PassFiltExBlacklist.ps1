Function Compare-PassFiltExBlacklist {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName,

        [Parameter(Mandatory=$True)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$SourceBlacklistPath,

        [Parameter(Mandatory=$False)]
        [switch]$IncludeEqual
    )
    $SourceBlackListContent = Get-Content -Path $SourceBlacklistPath
    $Output = @()
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
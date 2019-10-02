Function Compare-PasswordFilterBlacklist {
    <#
    .SYNOPSIS
        Compares a server's Password Filter Blacklist file to the master file and returns the differences.
    .DESCRIPTION
        Compares a server's Password Filter Blacklist file to the master file and returns the differences.

        The output object contains 3 attributes.
        ServerName - the name of the server to which the difference exists on.
        Token - The word in the Blacklist that does not exist on the other side.
        Side - Tells which side the token exists on.
            'OnServer' - If the token exists on the server file and not the source file.
            'OnSource' - If the token exists in the source file but not on the server file.
            'OnBoth'   - If the token exists on both the source file and the server file.
                         You will only see 'OnBoth' if you use the IncludeEqual switch parameter.
    .PARAMETER ServerName
        The name of the domain controller that you wish to compare the Blacklist on.
    .PARAMETER IncludeEqual
        Using this switch will make the command display Tokens that are equal instead of just the differences.
    .EXAMPLE
        PS C:\> Compare-PasswordFilterBlacklist -ServerName dc01

        This example will compare the blacklist file on the server 'dc01' with the source blacklist file.
    .EXAMPLE
        PS C:\> Compare-PasswordFilterBlacklist -ServerName dc01,dc02,dc03

        This example will compare the blackfile files on 'dc01', 'dc02', and 'dc03' with the source blacklist file.
    .INPUTS
        String
    .OUTPUTS
        PSObject
    .NOTES
        Written by Thomas Barratt
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
Function Get-PasswordFilterInfo {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string]$ServerName
    )
    $SourceBlackListPath = "\\sfhousanp01\it\Security_Team\Password_Filter\PWD-Blacklist\PassFiltExBlacklist.txt"

    If (Test-Path -Path $SourceBlackListPath) {
        $SourceBlacklistHash = Get-FileHash -Path $SourceBlackListPath
        $Targets = @()
        # If the ServerName parameter is used, set the targets to the value of the parameter.
        # If no parameter is used, programatically find all Domain Controllers.
        If ($ServerName) {
            $Targets += $ServerName
        } Else {
            $Targets += $(Get-AllDomainControllers)
        }
        $Output = @()
        ForEach ($Target in $Targets) {
            $BlacklistPath = "\\$Target\c$\windows\PWD-Blacklist\PassFiltExBlacklist.txt"
            $BlacklistExists = If (Test-Path -Path $BlacklistPath) {$True} Else {$False}
            If ($BlacklistExists -eq $True) {
                $BlacklistHash = (Get-FileHash -Path $BlacklistPath).Hash
                If ($BlacklistHash -eq $($SourceBlacklistHash.Hash)) {
                    $HashMatches = $True
                } Else {
                    $HashMatches = $False
                }
            } Else {
                $BlacklistHash = 'Not Available'
            }
            $BlacklistProps = @{
                'Path' = $BlackListPath
                'Exists' = $BlacklistExists
                'Hash' = $BlacklistHash
                'HashMatches' = $HashMatches
                'Content' = $(Get-Content -Path $BlacklistPath)
            }
            $Blacklist = New-Object -TypeName PSObject -Property $BlacklistProps

            $DLLPath = "\\$Target\c$\windows\system32\PassFiltEx.dll"
            $DLLExists = If (Test-Path -Path $DLLPath) {$True} Else {$False}
            If ($DLLExists -eq $True) {
                $DLLVersion = (Get-ItemProperty -Path $DLLPath | Select-Object -ExpandProperty VersionInfo).ProductVersion
            }
            $DLLProps = @{
                'Path' = $DLLPath
                'Exists' = $DLLExists
                'Version' = $DLLVersion
            }
            $DLL = New-object -TypeName PSObject -Property $DLLProps

            $OutputProps = @{
                'ServerName'=$Target
                'Blacklist' = $Blacklist
                'DLL' = $DLL
            }
            $Obj = New-Object -TypeName PSObject -Property $OutputProps
            $Output += $Obj
        }
    }
}
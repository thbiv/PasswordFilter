Function GetAllDomainControllers {
    [CmdletBinding()]
    Param ()
    $Servers = Get-ADDomainController -filter {isReadOnly -eq $False} | Select-Object -ExpandProperty HostName
    $Output = $Servers | Foreach-object {$_.split('.')[0]}
    Write-Output $Output
}
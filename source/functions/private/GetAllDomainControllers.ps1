Function GetAllDomainControllers {
    [CmdletBinding()]
    Param ()
    $Output = Get-ADDomainController -filter {isReadOnly -eq $False} | Select-Object -ExpandProperty HostName
    Write-Output $Output
}
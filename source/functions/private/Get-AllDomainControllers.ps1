Function Get-AllDomainControllers {
    [CmdletBinding()]
    Param ()
    $DCs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }
    $Output = @()
    ForEach ($Item in $DCs) {
        if ($item.domain -match "snda"){}
        elseif ($item.IsReadOnly -eq $True){}
        elseif ($item.domain -match "selene1") {
            $Output += $item.HostName
        }
    }
}
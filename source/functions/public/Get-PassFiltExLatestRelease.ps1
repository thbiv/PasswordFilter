Function Get-PassFiltExLatestRelease {
    <#
    .EXTERNALHELP PasswordFilter-help.xml
    #>
    [CmdletBinding()]
    Param ()
    $Params = @{
        'Uri' = 'https://api.github.com/repos/ryanries/PassFiltEx/releases/latest'
        'Headers' = @{"Accept"="application/json"}
        'Method' = 'Get'
        'UseBasicParsing' = $True
    }
    $Response = Invoke-RestMethod @Params
    Write-Output $(New-Object -TypeName PassFiltExRelease -ArgumentList $($Response.name),
                                                                        [version]$(($Response.name).TrimStart('v')),
                                                                        [datetime]$($Response.published_at),
                                                                        $($Response.assets.browser_download_url))
}
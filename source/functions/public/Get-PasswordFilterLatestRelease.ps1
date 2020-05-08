Function Get-PasswordFilterLatestRelease {
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
    $Props = @{
        'Name' = $($Response.name)
        'Version' = $(($Response.name).TrimStart('v'))
        'PublishedDate' = [datetime]$($Response.published_at)
        'DownloadURL' = $($Response.assets.browser_download_url)
    }
    Write-Output $(New-Object -TypeName PSObject -Property $Props)
}
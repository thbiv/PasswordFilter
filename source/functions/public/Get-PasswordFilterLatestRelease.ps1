Function Get-PasswordFilterLatestRelease {
    <#
    .SYNOPSIS
        Retrieves data on the latest release of PassFiltEx on Github.
    .DESCRIPTION
        Uses Github's Release API to get information on the latest release of the PassFiltEx AD password filter.
        The information retrieved is the release version and the download URL.
    .EXAMPLE
        PS C:\> Get-PasswordFilterLatestRelease
    .INPUTS
        None
    .OUTPUTS
        PSObject
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
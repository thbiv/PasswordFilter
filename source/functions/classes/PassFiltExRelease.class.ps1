Class PassFiltExRelease {
    [string]$Name
    [version]$Version
    [datetime]$PublishedDate
    [string]$DownloadURL

    PassFiltExRelease ([string]$Name,[version]$Version,[datetime]$PublishedDate,[string]$DownloadURL) {
        $this.Name = $Name
        $this.Version = $Version
        $this.PublishedDate = $PublishedDate
        $this.DownloadURL = $DownloadURL
    }

    [string]ToString() {
        return ("{0}[({1})({2})({3})]" -f $this.Name,$this.Version,$this.PublishedDate,$this.DownloadURL)
    }
}

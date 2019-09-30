Class PasswordFilterIssue {
    [string]$ServerName
    [string]$Token
    [string]$Side

    PasswordFilterIssue ([string]$ServerName,[string]$Token,[string]$Side) {
        $this.ServerName = $ServerName
        $this.Token = $Token
        $this.Side = $Side
    }

    [string]ToString() {
        return ("{0}|{1}|{2}" -f $this.ServerName,$this.Token,$this.Side)
    }
}
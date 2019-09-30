Class PasswordFilterStatus {
    [String]$ServerName
    [string]$BlackListPath
    [bool]$BlackListExists
    [string]$BlackListHash
    [bool]$BlackListCurrent
    [string]$DLLPath
    [bool]$DLLExists
    [string]$DLLVersion
    [bool]$UpgradeNeeded
    [bool]$Enabled

    PasswordFilterStatus ([String]$ServerName,[string]$BlackListPath,[bool]$BlackListExists,[string]$BlackListHash,[bool]$BlackListCurrent,[string]$DLLPath,[bool]$DLLExists,[string]$DLLVersion,[bool]$UpgradeNeeded,[bool]$Enabled) {
        $this.ServerName = $ServerName
        $this.BlackListPath = $BlackListPath
        $this.BlackListExists = $BlackListExists
        $this.BlackListHash = $BlackListHash
        $this.BlackListCurrent = $BlackListCurrent
        $this.DLLPath = $DLLPath
        $this.DLLExists = $DLLExists
        $this.DLLVersion = $DLLVersion
        $this.UpgradeNeeded = $UpgradeNeeded
        $this.Enabled = $Enabled
    }

    [string]ToString() {
        return ("[{0}] Blacklist[Exists:{1} Current:{2}] DLL[Exists:{3} Upgrade:{4}] Enabled:{5}" -f $this.ServerName,$this.BlackListExists,$this.BlackListCurrent,$this.DLLExists,$this.UpgradeNeeded,$this.Enabled)
    }
}
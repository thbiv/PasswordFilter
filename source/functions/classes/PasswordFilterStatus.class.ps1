Class PasswordFilterStatus {
    [String]$ServerName
    [bool]$BlackListExists
    [bool]$BlackListCurrent
    [bool]$DLLExists
    [string]$DLLVersion
    [bool]$UpgradeNeeded
    [bool]$Enabled

    PasswordFilterStatus ([String]$ServerName,[bool]$BlackListExists,[bool]$BlackListCurrent,[bool]$DLLExists,[string]$DLLVersion,[bool]$UpgradeNeeded,[bool]$Enabled) {
        $this.ServerName = $ServerName
        $this.BlackListExists = $BlackListExists
        $this.BlackListCurrent = $BlackListCurrent
        $this.DLLExists = $DLLExists
        $this.DLLVersion = $DLLVersion
        $this.UpgradeNeeded = $UpgradeNeeded
        $this.Enabled = $Enabled
    }

    [string]ToString() {
        return ("[{0}] Blacklist[Exists:{1} Current:{2}] DLL[Exists:{3} Upgrade:{4}] Enabled:{5}" -f $this.ServerName,$this.BlackListExists,$this.BlackListCurrent,$this.DLLExists,$this.UpgradeNeeded,$this.Enabled)
    }
}
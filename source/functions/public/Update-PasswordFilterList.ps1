Function Update-PasswordFilterList {
    <#
    .SYNOPSIS
        Updates the Blacklist text file on domain controllers.
    .DESCRIPTION
        This command first checks to see if the Blacklist file is present. If it is, it gets a hash of the file and compares it to
        the hash of the master file. If they do not match, the master file is copied to the server, replacing the file that is already there.
        If the file does not already exist on the server, or if the hash matches with the master file, the file copy is not executed.
    .PARAMETER ServerName
        Server hostname or list of hostnames
    .EXAMPLE
        PS C:\> Update-PasswordFilterList.ps1 -ServerName dc01

        This example will update the Blacklist text file on dc01 if the file does not match the master file.
    .EXAMPLE
        PS C:\> Update-PasswordFilterList.ps1 -ServerName dc01,dc02,dc03

        This example will update the blacklist file on dc01,dc02, and dc03 if the file does not match the master file.
    .EXAMPLE
        PS C:\> Update-PasswordFilterList.ps1

        This example will update the blacklist file on all writable domain controllers in the domain if the file does not match the master file.
    .INPUTS
        string
    .OUTPUTS
        None
    .LINK
        https://github.com/ryanries/PassFiltEx/releases
    .LINK
        https://github.com/ryanries/PassFiltEx/blob/master/README.md
    .NOTES
        Written by Thomas Barratt
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string[]]$ServerName
    )
    $Targets = @()
    If ($ServerName) {
        $Targets += $ServerName
    } Else {
        $Targets += $(GetAllDomainControllers)
    }
    $Blacklist = $((GetPasswordFilterSourcePaths).Blacklist)
    $BlacklistHash = Get-FileHash -Path $Blacklist
    ForEach ($Target in $Targets) {
        $TargetDir = "\\$Target\c$\windows\system32"
        If(!(Test-Path -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt'))){
            Write-Warning "[PasswordFilter][$Target][BlacklistFile] File does not exist: $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')"
            Write-Warning "[PasswordFilter][$Target][BlacklistFile] PasswordFilter may need to be installed first"
        } Else {
            $TestHash = Get-FileHash -Path $(Join-Path -Path $TargetDir -ChildPath 'PassFiltExBlacklist.txt')
            If ($($TestHash.Hash) -eq $($BlacklistHash.Hash)) {
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes match"
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] File Copy Skipped"
            } Else {
                Write-Verbose "[PasswordFilter][$Target][BlacklistFile] Payload and Target Hashes do not match"
                If ($PSCmdlet.ShouldProcess("$Target","Copy File: PassFiltExBlacklist.txt")) {
                    Try {
                        Copy-Item -Path $Blacklist -Destination $TargetDir -ErrorAction Stop
                    } Catch {
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning $ErrorMessage
                    }
                }
            }
        }
    }
}
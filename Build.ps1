[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False,Position=0)]
    [ValidateSet('.','Testing')]
    [string]$BuildTask = '.',

    [switch]$BumpMajorVersion,

    [switch]$BumpMinorVersion
)

Write-Host "Bootstrap Environment"
If (-not(Get-PackageProvider -Name Nuget)) {
    Install-PackageProvider -Name Nuget -Force -Scope CurrentUser
    Write-Host "Installed Nuget package provider"
} Else {Write-Host "Nuget package provider already installed"}

[xml]$ModuleConfig = Get-Content Module.Config.xml
$RequiredModules = $ModuleConfig.requires.modules.module
ForEach ($Module in $RequiredModules) {
    If (-not(Get-Module -Name $Module -ListAvailable)) {
        $Params = @{
            Name = $($Module.name)
            Scope = 'CurrentUser'
            Force = $True
        }
        If ($Null -ne $Module.version) {$Params += @{RequiredVersion = $($Module.version)}}
        If ($Null -ne $Module.repository) {$Params += @{Repository = $($Module.repository)}}
        Install-Module @Params
    }
    If (-not(Get-Module -Name $Module)) {
        Import-Module -Name $Module
    }
}

$Params = @{
    Task = $BuildTask
    File = 'PasswordFilter.build.ps1'
}
If ($BumpMajorVersion) {
    $Params.Add('BumpMajorVersion',$True)
}
If ($BumpMinorVersion) {
    $Params.Add('BumpMinorVersion',$True)
}
Invoke-Build @Params
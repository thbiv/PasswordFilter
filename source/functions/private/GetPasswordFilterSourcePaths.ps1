Function GetPasswordFilterSourcePaths {
    $SourcePaths = @{
        Blacklist = '\\sfhrsfile01\shared\Horsham-IT\Password_Filter\Production\PassFiltExBlacklist.txt'
        DLL = '\\sfhrsfile01\shared\Horsham-IT\Password_Filter\Production\PassFiltEx.dll'
    }
    Write-Output $SourcePaths
}
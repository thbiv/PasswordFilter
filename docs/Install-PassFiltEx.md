---
external help file: PasswordFilter-help.xml
Module Name: PasswordFilter
online version: https://github.com/thbiv/PasswordFilter/blob/master/docs/Install-PassFiltEx.md
schema: 2.0.0
---

# Install-PassFiltEx

## SYNOPSIS
Remotely Installs the PassFiltEx AD Password Filter onto domain controllers.

## SYNTAX

```
Install-PassFiltEx [[-ServerName] <String[]>] -SourceDLLPath <String> -SourceBlacklistPath <String> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
To install the PassFiltEx password filter, this command will:
1.
Copy the DLL file of the password filter (PassFiltEx.dll) to: C:\Windows\System32
2.
Copy the Blacklist text file (PassFiltExBlacklist.txt) to: C:\Windows\System32
3.
Modify the Notification Packages registry entry at HKLM:\SYSTEM\CurrentControlSet\Control\LSA to include 'PassFiltEx'
After all 3 steps are complete.
The domain controller will need to be rebooted for the Password Filter to start working.

Because this command does check to see if the files and registry entry is present already, this can be used to upgrade the password filter as well.

## EXAMPLES

### EXAMPLE 1
```
Install-PassFiltEx -ServerName dc01
```

This example will install the password filter onto the domain controller named dc01.

### EXAMPLE 2
```
Install-PassFiltEx -ServerName dc01,dc02,dc03
```

This example will install the password filter on the 3 listed domain controllers, dc01,dc02,dc03.

### EXAMPLE 3
```
Install-PassFiltEx
```

This example will install the password filter on all writable domain controllers in the current domain.

## PARAMETERS

### -ServerName
Server hostname or list of hostnames

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceBlacklistPath
The path to the source blacklist file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceDLLPath
The path to the source DLL file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### string
## OUTPUTS

### None
## NOTES
Written by Thomas Barratt

## RELATED LINKS


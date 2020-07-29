---
external help file: PasswordFilter-help.xml
Module Name: PasswordFilter
online version: 
schema: 2.0.0
---

# Update-PassFiltExBlacklist

## SYNOPSIS
Remotely Updates the Blacklist text file on domain controllers.

## SYNTAX

```
Update-PassFiltExBlacklist [[-ServerName] <String[]>] -SourceBlacklistPath <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This command first checks to see if the Blacklist file is present.
If it is, it gets a hash of the file and compares it to
the hash of the master file.
If they do not match, the master file is copied to the server, replacing the file that is already there.
If the file does not already exist on the server, or if the hash matches with the master file, the file copy is not executed.

## EXAMPLES

### EXAMPLE 1
```
Update-PassFiltExBlacklist -ServerName dc01
```

This example will update the Blacklist text file on dc01 if the file does not match the master file.

### EXAMPLE 2
```
Update-PassFiltExBlacklist -ServerName dc01,dc02,dc03
```

This example will update the blacklist file on dc01,dc02, and dc03 if the file does not match the master file.

### EXAMPLE 3
```
Update-PassFiltExBlacklist
```

This example will update the blacklist file on all writable domain controllers in the domain if the file does not match the master file.

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


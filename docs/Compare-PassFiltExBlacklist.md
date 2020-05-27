---
external help file: PasswordFilter-help.xml
Module Name: PasswordFilter
online version:
schema: 2.0.0
---

# Compare-PassFiltExBlacklist

## SYNOPSIS
Compares a server's Password Filter Blacklist file to the master file and returns the differences.

## SYNTAX

```
Compare-PassFiltExBlacklist [[-ServerName] <String[]>] [-IncludeEqual] [<CommonParameters>]
```

## DESCRIPTION
Compares a server's Password Filter Blacklist file to the master file and returns the differences.

The output object contains 3 attributes.
ServerName - the name of the server to which the difference exists on.
Token - The word in the Blacklist that does not exist on the other side.
Side - Tells which side the token exists on.
    'OnServer' - If the token exists on the server file and not the source file.
    'OnSource' - If the token exists in the source file but not on the server file.
    'OnBoth'   - If the token exists on both the source file and the server file.
                 You will only see 'OnBoth' if you use the IncludeEqual switch parameter.

## EXAMPLES

### EXAMPLE 1
```
Compare-PassFiltExBlacklist -ServerName dc01
```

This example will compare the blacklist file on the server 'dc01' with the source blacklist file.

### EXAMPLE 2
```
Compare-PassFiltExBlacklist -ServerName dc01,dc02,dc03
```

This example will compare the blackfile files on 'dc01', 'dc02', and 'dc03' with the source blacklist file.

## PARAMETERS

### -ServerName
The name of the domain controller that you wish to compare the Blacklist on.

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

### -IncludeEqual
Using this switch will make the command display Tokens that are equal instead of just the differences.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
## OUTPUTS

### PasswordFilterBlacklistCompare
## NOTES
Written by Thomas Barratt

## RELATED LINKS

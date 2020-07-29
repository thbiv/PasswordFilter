---
external help file: PasswordFilter-help.xml
Module Name: PasswordFilter
online version: 
schema: 2.0.0
---

# Get-PassFiltExStatus

## SYNOPSIS
Remotely Gets Password Filter status from domain controllers

## SYNTAX

```
Get-PassFiltExStatus [[-ServerName] <String[]>] -SourceDLLPath <String> -SourceBlacklistPath <String>
 [<CommonParameters>]
```

## DESCRIPTION
Returns the Password Filter status of domain controllers as a PSObject.
The PSObject returned contains the following attributes:

ServerName - The hostname of the server that the object describes.
BlacklistExists - True is the Blacklist is present.
False if it is not.
BlacklistCurrent - True is the file hash matches the master file.
False if it does not.
This means the Blacklist needs to be updated.
DLLVersion - The version number of the DLL file.
This is the version of the Password filter itself.
Enabled - True is it is enabled, False if it is not.
This checks the Notification Packages registry setting looking for PassFiltEx to be present.
UpgradeNeeded - True is the DLL needs to be upgraded.
False if it does not.
Checks the source DLL file's version and compares it with what is on the domain controller.

## EXAMPLES

### EXAMPLE 1
```
Get-PassFiltExStatus -ServerName dc01
```

This example will get the Password Filter status for dc01

### EXAMPLE 2
```
Get-PassFiltExStatus -ServerName dc01,dc02,dc03
```

This example will get the Password Filter status for the servers dc01, dc02, and dc03

### EXAMPLE 3
```
Get-PassFiltExStatus
```

This example will get the Password Filter status for all writable domain controllers in the domain.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
## OUTPUTS

### PasswordFilterStatus
## NOTES
Written By Thomas Barratt

## RELATED LINKS


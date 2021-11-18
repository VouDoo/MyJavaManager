---
external help file: MyJavaManager-help.xml
Module Name: MyJavaManager
online version:
schema: 2.0.0
---

# Add-JavaEntry

## SYNOPSIS
Add a Java entry.

## SYNTAX

```
Add-JavaEntry [-Path] <String> [-CustomName <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Add a Java entry to the inventory file.

## EXAMPLES

### EXAMPLE 1
```
Add-JavaEntry -Path C:\path\to\java_home_directory
```

Add java entry to the inventory with default name (version name).

### EXAMPLE 2
```
Add-JavaEntry -Path C:\path\to\java_home_directory -CustomName "MyJava"
```

Add java entry to the inventory with custom name.

## PARAMETERS

### -Path
Path to the Java home directory to add as entry to the inventory file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomName
Custom name to set for the Java entry to add to the inventory file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Add-JavaEntry.
## OUTPUTS

### System.Void. None.
## NOTES

## RELATED LINKS

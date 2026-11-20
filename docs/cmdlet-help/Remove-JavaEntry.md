---
external help file: MyJavaManager-help.xml
Module Name: MyJavaManager
online version:
schema: 2.0.0
---

# Remove-JavaEntry

## SYNOPSIS
Remove a Java entry.

## SYNTAX

```
Remove-JavaEntry [[-Name] <String>] [-RemoveDirectory] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove a Java entry from the inventory file.
Optionally, also remove its Java home directory from the disk.

## EXAMPLES

### EXAMPLE 1
```
Remove-JavaEntry -Name undesired_java
```

Remove a Java entry with defined name from the inventory file.

### EXAMPLE 2
```
Remove-JavaEntry -Name jdk-11.0.13.0 -RemoveDirectory
```

Remove a Java entry from the inventory file and its Java home directory from the disk.

## PARAMETERS

### -Name
Name of the Java entry to remove from the inventory file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveDirectory
Also remove the Java home directory of the entry from the disk.
The directory is removed before the entry; if it cannot be removed, the entry is kept.
Nothing is removed if the directory is not a Java home directory or if it is the current JAVA_HOME.
The directory is kept (only the entry is removed) if other Java entries use it.

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

### None. You cannot pipe objects to Remove-JavaEntry.
## OUTPUTS

### System.Void. None.
## NOTES

## RELATED LINKS

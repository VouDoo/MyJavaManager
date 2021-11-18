---
external help file: MyJavaManager-help.xml
Module Name: MyJavaManager
online version:
schema: 2.0.0
---

# Switch-JavaVersion

## SYNOPSIS
Switch Java version.

## SYNTAX

### UseInventory (Default)
```
Switch-JavaVersion [[-Name] <String>] [-Target <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UsePath
```
Switch-JavaVersion -Path <String> [-Target <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Switch the version of Java which is being used in a specific environment target scope.

## EXAMPLES

### EXAMPLE 1
```
Switch-JavaVersion -Name MyJava
```

Select a Java version which is defined in the inventory file and use it in default scope (user scope).

### EXAMPLE 2
```
Switch-JavaVersion
```

(Interactive menu)

Select a Java version which is defined in the inventory file using an interactive menu and use it in default scope (user scope).

### EXAMPLE 3
```
Switch-JavaVersion -Name MyJava -Target Process
```

Select a Java version which is defined in the inventory file and use it in process scope.

### EXAMPLE 4
```
Switch-JavaVersion -Path C:\path\to\java_home_directory
```

Use the Java version from the given path to a Java home directory in default scope (user scope).

## PARAMETERS

### -Name
Name of the Java entry from the inventory file to use.

```yaml
Type: String
Parameter Sets: UseInventory
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to the Java home directory to use.

```yaml
Type: String
Parameter Sets: UsePath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target
Target scope of the environment variable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: User
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

### None. You cannot pipe objects to Switch-JavaVersion.
## OUTPUTS

### System.Void. None.
## NOTES

## RELATED LINKS

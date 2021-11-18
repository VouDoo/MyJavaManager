---
external help file: MyJavaManager-help.xml
Module Name: MyJavaManager
online version:
schema: 2.0.0
---

# Invoke-DownloadJavaPackage

## SYNOPSIS
Download a Java package.

## SYNTAX

```
Invoke-DownloadJavaPackage [[-Version] <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Download and install a Java package from Adoptium and add an associated entry to the inventory file.

## EXAMPLES

### EXAMPLE 1
```
Invoke-DownloadJavaPackage
```

If in interactive PowerShell session, select a version of Java using menu.
Else, pick the latest available version of Java.
Download and install the Java package in the .java_package folder.

### EXAMPLE 2
```
Invoke-DownloadJavaPackage -Version 11
```

Download and install Java 11 in the .java_package folder.

## PARAMETERS

### -Version
Version of Java to download.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
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

### None. You cannot pipe objects to Invoke-DownloadJavaPackage.
## OUTPUTS

### System.Void. None.
## NOTES

## RELATED LINKS

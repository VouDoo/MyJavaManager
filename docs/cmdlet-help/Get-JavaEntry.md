---
external help file: MyJavaManager-help.xml
Module Name: MyJavaManager
online version:
schema: 2.0.0
---

# Get-JavaEntry

## SYNOPSIS
Get Java entries.

## SYNTAX

```
Get-JavaEntry [<CommonParameters>]
```

## DESCRIPTION
Get all the Java entries from the inventory file.

## EXAMPLES

### EXAMPLE 1
```
Get-JavaEntry
```

Name           Path
----           ----
jdk-8.0.3120.7 C:\Users\user\.java_packages\jdk8u312-b07
jdk-11.0.13.0  C:\Users\user\.java_packages\jdk-11.0.13+8
jdk-17.0.1.0   C:\Users\user\.java_packages\jdk-17.0.1+12
my_jdk         C:\Users\user\.java_packages\jdk-17.0.1+12

Get all the Java entries from the inventory file.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-JavaEntry.
## OUTPUTS

### System.Object. Array of Java entry objects.
## NOTES

## RELATED LINKS

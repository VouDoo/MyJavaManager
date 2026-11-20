#
# Script module for module 'MyJavaManager'
#

#Requires -Version 5.1

# The module relies on the Windows Registry, user32.dll and java.exe: it is Windows-only.
# ($IsWindows does not exist in Windows PowerShell 5.1, which always runs on Windows.)
if ($PSVersionTable.PSEdition -eq "Core" -and -not $IsWindows) {
    throw "MyJavaManager only supports Windows."
}

#using namespace System.Management.Automation

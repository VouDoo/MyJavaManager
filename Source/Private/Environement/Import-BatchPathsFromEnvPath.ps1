function Import-BatchPathsFromEnvPath {

    <#

    .SYNOPSIS
    Imports paths including Batch variables from Path environment variable.

    .DESCRIPTION
    This function uses an WshShell Object to read the value of the Path
    environment variable from the Windows Registry.
    The motivation is to keep the batch variables in the value.
    This is only available for the Machine and User target scopes.

    .PARAMETER Target
    Target scope of the environment variable.

    .INPUTS
    None. You cannot pipe objects to Import-BatchPathsFromEnvPath.

    .OUTPUTS
    System.String[]. Array of Batch paths.

    .EXAMPLE
    PS> Import-BatchPathsFromEnvPath -Target Machine
    C:\windows
    %SystemRoot%\system32
    %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\

    Returns an array which contains every path currently set in the Path environment variable.

    .LINK
    - Batch "Windows Environment Variables" documentation: https://ss64.com/nt/syntax-variables.html
    - PowerShell "working with registry entries" documentation: https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries

    #>

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Target scope of the environment variable"
        )]
        [ValidateSet("Machine", "User")]
        [string] $Target
    )

    process {
        $WScriptShell = New-Object -ComObject WScript.Shell

        $Value = switch ($Target) {
            "Machine" {
                $WScriptShell.RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path")
            }
            "User" {
                $WScriptShell.RegRead("HKEY_CURRENT_USER\Environment\Path")
            }
        }
        Write-Debug -Message "Current value of the Path environement variable in $Target scope: `"$Value`"."

        $Value -split [System.IO.Path]::PathSeparator | Where-Object -FilterScript { $_ } | Select-Object -Unique
    }
}

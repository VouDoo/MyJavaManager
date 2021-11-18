function Export-BatchPathsToEnvPath {

    <#

    .SYNOPSIS
    Export paths including Batch variables to Path environment variable.

    .DESCRIPTION
    This function uses a Microsoft.Win32.Registry method to write
    the value of the Path environment variable to the Windows Registry.
    The motivation is to keep the batch variables in the value.
    This is only available for the Machine and User target scopes.

    .PARAMETER Paths
    Array of paths to export to the Path environment variable.

    .PARAMETER Target
    Target scope of the environment variable.

    .INPUTS
    None. You cannot pipe objects to Export-BatchPathsToEnvPath.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Export-BatchPathsToEnvPath -Value $ArrayOfPaths -Target Machine

    Set Path environment variables with the given paths.

    .LINK
    - Batch "Windows Environment Variables" documentation: https://ss64.com/nt/syntax-variables.html
    - PowerShell "working with registry entries" documentation: https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Array of paths to set in the Path environment variable"
        )]
        [string[]] $Paths,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Target scope of the environment variable"
        )]
        [ValidateSet("Machine", "User")]
        [string] $Target
    )

    process {
        $Value = $Paths -join [System.IO.Path]::PathSeparator

        if ($PSCmdlet.ShouldProcess("Path environment variable in '$Target' scope", "Set value to '$Value'")) {
            $KeyName = switch ($Target) {
                "Machine" {
                    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path"
                }
                "User" {
                    "HKEY_CURRENT_USER\Environment"
                }
            }
            [Microsoft.Win32.Registry]::SetValue($KeyName, "Path", $Value, [Microsoft.Win32.RegistryValueKind]::ExpandString)
            Write-Debug -Message "New value of the Path environement variable in $Target scope: `"$Value`"."
        }
    }
}

function Update-EnvPath {

    <#

    .SYNOPSIS
    Update the Path environment variable.

    .DESCRIPTION
    Update the Path environment variable in the current session.

    .INPUTS
    None. You cannot pipe objects to Update-EnvPath.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Update-EnvPath

    Update the Path environment variable.

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ()

    begin {
        $Separator = [System.IO.Path]::PathSeparator
    }

    process {
        if ($PSCmdlet.ShouldProcess("Update the Path environment variable in the current session")) {
            $Paths = "Machine", "User" | ForEach-Object -Process {
                [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::"$_") -split $Separator | Where-Object -FilterScript { $_ } | Select-Object -Unique
            }
            $env:Path = $Paths -join $Separator
            Write-Debug "Path environment variable has been updated in the current session."
        }
    }
}

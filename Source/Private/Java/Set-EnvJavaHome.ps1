function Set-EnvJavaHome {

    <#

    .SYNOPSIS
    Set JAVA_HOME environment variable.

    .DESCRIPTION
    Set JAVA_HOME environment variable in a target scope.

    .PARAMETER Path
    Path to the Java home directory.

    .PARAMETER Target
    Target scope of the environment variable.

    .INPUTS
    None. You cannot pipe objects to Set-EnvJavaHome.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Set-EnvJavaHome -Path C:\path\to\java_home_directory -Target User

    Set JAVA_HOME environment variable with given path in user scope.

    .NOTES
    BUG REG_EXPAND_SZ environment variables not properly expanded for shells (related Github issue: https://github.com/microsoft/terminal/issues/9741)

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Path to the Java home directory"
        )]
        [string] $Path,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Target scope of the environment variable"
        )]
        [ValidateSet("Machine", "User", "Process")]
        [string] $Target
    )

    process {
        $NormalizedPath = [PathFormat]::NormalizePath($Path)
        $PreviousValue = $env:JAVA_HOME

        if ($PSCmdlet.ShouldProcess("JAVA_HOME environment variable in '$Target' scope", "Set value to '$NormalizedPath'")) {
            if ($Target -ne "Process") {
                try {
                    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $NormalizedPath, [System.EnvironmentVariableTarget]::"$Target")
                    Write-Debug -Message "JAVA_HOME environment variable in $Target scope has been set to `"$NormalizedPath`"."
                }
                catch {
                    throw "Cannot set JAVA_HOME environment variable in $Target scope: {0}" -f $_.Exception.Message
                }
            }
            $env:JAVA_HOME = $NormalizedPath
        }

        if ($Target -ne "Process") {
            $BatchPaths = Import-BatchPathsFromEnvPath -Target $Target
            if ($BatchPaths -notcontains "%JAVA_HOME%\bin") {
                if ($PSCmdlet.ShouldProcess("Path environment variable in '$Target' scope", "Add path '%JAVA_HOME%\bin'")) {
                    $BatchPaths += "%JAVA_HOME%\bin"
                    try {
                        Export-BatchPathsToEnvPath -Paths $BatchPaths -Target $Target
                        Write-Debug -Message "`"%JAVA_HOME%\bin`" has been added to the Path environment variable in $Target scope."
                    }
                    catch {
                        throw "Cannot add `"%JAVA_HOME%\bin`" to Path environment variable in $Target scope: {0}" -f $_.Exception.Message
                    }
                    Send-WMSettingChangeMessage
                }
            }
            else {
                Write-Debug -Message "`"%JAVA_HOME%\bin`" is already present in the Path environment variable in $Target scope."
            }
        }

        # Update the Path of the current session: remove any previous Java bin entry
        # (exact match, case-insensitive) and put the new one first, keeping every other entry.
        $NewBinPath = "$NormalizedPath\bin"
        if ($PSCmdlet.ShouldProcess("Path environment variable in Process scope", "Use '$NewBinPath'")) {
            $Separator = [System.IO.Path]::PathSeparator
            $BinPathsToRemove = @("%JAVA_HOME%\bin", $NewBinPath)
            if ($PreviousValue) {
                $BinPathsToRemove += "{0}\bin" -f $PreviousValue.TrimEnd("\")
            }

            $Entries = $env:Path -split [regex]::Escape($Separator) | Where-Object -FilterScript {
                $_ -and $_.TrimEnd("\") -notin $BinPathsToRemove
            }
            $env:Path = (@($NewBinPath) + @($Entries)) -join $Separator
            Write-Debug -Message "`"$NewBinPath`" has been set first in the Path environment variable in Process scope."
        }
    }
}

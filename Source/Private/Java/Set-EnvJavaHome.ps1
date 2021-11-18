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
                    Update-EnvPathProcess
                }
            }
            else {
                Write-Debug -Message "`"%JAVA_HOME%\bin`" is already present in the Path environment variable in $Target scope."
            }
        }

        if ($PreviousValue) {
            $env:Path = $env:Path.Replace($PreviousValue, $NormalizedPath)
            Write-Debug -Message "JAVA_HOME path from the Path environment variable in Process scope has been updated to `"$NormalizedPath`"."
        }
        else {
            if ($Target -ne "Process") {
                $env:Path = $env:Path.Replace("%JAVA_HOME%", $NormalizedPath)
                Write-Debug -Message "`"%JAVA_HOME%`" from the Path environment variable in Process scope has been replaced by `"$NormalizedPath`"."
            }
            else {
                $PathToAppend = "{0}$NormalizedPath\bin" -f [System.IO.Path]::PathSeparator
                $env:Path += $PathToAppend
                Write-Debug -Message "`"$PathToAppend`" has been appended to the Path environment variable in Process scope."
            }
        }
    }
}

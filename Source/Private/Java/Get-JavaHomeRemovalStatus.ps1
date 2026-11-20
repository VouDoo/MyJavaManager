function Get-JavaHomeRemovalStatus {

    <#

    .SYNOPSIS
    Get the removal status of a Java home directory.

    .DESCRIPTION
    Tell whether the Java home directory of a Java entry can be safely removed from the disk.

    The returned object has a Status property, which is one of:
    - Removable: the directory can be removed.
    - Missing: the directory does not exist (nothing to remove).
    - NotJavaHome: the directory exists but is not a Java home directory.
    - InUse: the directory is the current JAVA_HOME (Process, User or Machine scope).
    - Shared: the directory is also used by other Java entries (listed in the SharedWith property).

    .PARAMETER Path
    Path to the Java home directory of the Java entry to remove.

    .PARAMETER OtherEntries
    The other Java entries of the inventory (i.e. without the one to remove).

    .INPUTS
    None. You cannot pipe objects to Get-JavaHomeRemovalStatus.

    .OUTPUTS
    System.Management.Automation.PSCustomObject. Object with Status and SharedWith properties.

    .EXAMPLE
    PS> Get-JavaHomeRemovalStatus -Path C:\path\to\java_home_directory -OtherEntries $OtherEntries

    Status    SharedWith
    ------    ----------
    Removable {}

    Get the removal status of a Java home directory.

    #>

    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Path to the Java home directory of the Java entry to remove"
        )]
        [string] $Path,

        [Parameter(
            HelpMessage = "The other Java entries of the inventory"
        )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]] $OtherEntries = @()
    )

    process {
        $NormalizedPath = [PathFormat]::NormalizePath($Path)
        $SharedWith = @()

        $Status = if (-not (Test-Path -Path $NormalizedPath)) {
            "Missing"
        }
        elseif (-not (Test-JavaHomeDirectory -Path $NormalizedPath)) {
            "NotJavaHome"
        }
        else {
            # Current JAVA_HOME values (paths are compared case-insensitively, as on Windows)
            $JavaHomes = @(
                $env:JAVA_HOME
                [System.Environment]::GetEnvironmentVariable("JAVA_HOME", [System.EnvironmentVariableTarget]::User)
                [System.Environment]::GetEnvironmentVariable("JAVA_HOME", [System.EnvironmentVariableTarget]::Machine)
            ) | Where-Object -FilterScript { $_ } | ForEach-Object -Process {
                try { [PathFormat]::NormalizePath($_) } catch { Write-Debug -Message "Ignoring invalid JAVA_HOME value `"$_`"." }
            }

            $SharedWith = @(
                $OtherEntries | Where-Object -FilterScript {
                    $_ -and $_.Path -and [PathFormat]::NormalizePath($_.Path) -eq $NormalizedPath
                } | ForEach-Object -Process { $_.Name }
            )

            if ($NormalizedPath -in $JavaHomes) {
                "InUse"
            }
            elseif ($SharedWith.Count -gt 0) {
                "Shared"
            }
            else {
                "Removable"
            }
        }
        Write-Debug -Message "Removal status of `"$NormalizedPath`" is `"$Status`"."

        [pscustomobject]@{
            Status     = $Status
            SharedWith = $SharedWith
        }
    }
}

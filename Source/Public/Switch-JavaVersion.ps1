function Switch-JavaVersion {

    <#

    .SYNOPSIS
    Switch Java version.

    .DESCRIPTION
    Switch the version of Java which is being used in a specific environment target scope.

    .PARAMETER Name
    Name of the Java entry from the inventory file to use.

    .PARAMETER Path
    Path to the Java home directory to use.

    .PARAMETER Target
    Target scope of the environment variable.

    .INPUTS
    None. You cannot pipe objects to Switch-JavaVersion.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Switch-JavaVersion -Name MyJava

    Select a Java version which is defined in the inventory file and use it in default scope (user scope).

    .EXAMPLE
    PS> Switch-JavaVersion

    (Interactive menu)

    Select a Java version which is defined in the inventory file using an interactive menu and use it in default scope (user scope).

    .EXAMPLE
    PS> Switch-JavaVersion -Name MyJava -Target Process

    Select a Java version which is defined in the inventory file and use it in process scope.

    .EXAMPLE
    PS> Switch-JavaVersion -Path C:\path\to\java_home_directory

    Use the Java version from the given path to a Java home directory in default scope (user scope).

    #>

    [OutputType([void])]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = "UseInventory"
    )]
    param (
        [Parameter(
            ParameterSetName = "UseInventory",
            Position = 0,
            HelpMessage = "Name of the Java entry from the inventory file to use"
        )]
        [string] $Name,

        [Parameter(
            ParameterSetName = "UsePath",
            Mandatory = $true,
            HelpMessage = "Path to the Java home directory to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter(
            HelpMessage = "Target scope of the environment variable"
        )]
        [ValidateSet("Machine", "User", "Process")]
        [string] $Target = "User"
    )

    begin {
        $InformationPreference = "Continue"
        $ErrorActionPreference = "Stop"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "UseInventory") {
            $Inventory = New-Object -TypeName Inventory

            if (-not $Inventory.FileExists()) {
                Write-Error -Message "The inventory file does not exist."
            }

            $Inventory.ReadFile()

            if (-not $Inventory.JavaEntries) {
                Write-Error -Message "There is no Java entry in the inventory."
            }

            $JavaEntryNames = @()
            $Inventory.JavaEntries | ForEach-Object -Process {
                $JavaEntryNames += $_.Name
            }

            if (-not $Name) {
                if ([Environment]::UserInteractive) {
                    $Name = Use-InteractiveSelectionMenu -Items $JavaEntryNames -Header "Select Java entry:"
                    if (-not $Name) { break }
                }
                else {
                    Write-Error -Message "Parameter `"Name`" cannot be an empty string."
                }
            }

            if (-not $Inventory.JavaEntryExists($Name)) {
                Write-Error -Message "Java entry with name `"$Name`" does not exist."
            }

            $Path = $Inventory.GetJavaEntry($Name).Path
        }

        if (-not (Test-JavaHomeDirectory -Path $Path)) {
            Write-Error -Message "Path `"$Path`" is not a Java home directory."
        }

        $Version = Get-JavaVersion -Path $Path

        if ($PSCmdlet.ShouldProcess("Java home directory in '$Target' scope", "Use $Path")) {
            Set-EnvJavaHome -Path $Path -Target $Target
            Write-Information -MessageData "Java version `"$Version`" is now in use."
        }
    }
}

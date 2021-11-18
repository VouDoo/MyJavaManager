function Add-JavaEntry {

    <#

    .SYNOPSIS
    Add a Java entry.

    .DESCRIPTION
    Add a Java entry to the inventory file.

    .PARAMETER Path
    Path to the Java home directory to add as entry to the inventory file.

    .PARAMETER CustomName
    Custom name to set for the Java entry to add to the inventory file.

    .INPUTS
    None. You cannot pipe objects to Add-JavaEntry.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Add-JavaEntry -Path C:\path\to\java_home_directory

    Add java entry to the inventory with default name (version name).

    .EXAMPLE
    PS> Add-JavaEntry -Path C:\path\to\java_home_directory -CustomName "MyJava"

    Add java entry to the inventory with custom name.

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the Java home directory to add as entry to the inventory file"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter(
            HelpMessage = "Custom name to set for the Java entry to add to the inventory file"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [string] $CustomName
    )

    begin {
        $InformationPreference = "Continue"
        $ErrorActionPreference = "Stop"
    }

    process {
        if (-not (Test-JavaHomeDirectory -Path $Path)) {
            Write-Error -Message "Path `"$Path`" is not a Java home directory."
        }

        $Version = Get-JavaVersion -Path $Path
        Write-Debug -Message "Java version is `"$Version`"."

        $Name = if ($CustomName) { $CustomName } else { $Version }
        Write-Debug -Message "Java entry will be set with name `"$Name`"."

        $Inventory = New-Object -TypeName Inventory

        if ($Inventory.FileExists()) {
            $Inventory.ReadFile()
        }

        if ($Inventory.JavaEntryExists($Name)) {
            Write-Error -Message "Java entry `"$Name`" already exists."
        }

        if ($PSCmdlet.ShouldProcess($Inventory.Path, "Add Java entry '$Name' to inventory file")) {
            $Inventory.AddJavaEntry($Name, $Path)
            $Inventory.SaveFile()
            Write-Information -MessageData "Java entry `"$Name`" added."
        }
    }
}

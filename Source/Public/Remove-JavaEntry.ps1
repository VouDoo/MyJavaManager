function Remove-JavaEntry {

    <#

    .SYNOPSIS
    Remove a Java entry.

    .DESCRIPTION
    Remove a Java entry to the inventory file.

    .PARAMETER Name
    Name of the Java entry to remove from the inventory file.

    .INPUTS
    None. You cannot pipe objects to Remove-JavaEntry.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Remove-JavaEntry -Name undesired_java

    Remove a Java entry with defined name from the inventory file.

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Position = 0,
            HelpMessage = "Name of the Java entry to remove from the inventory file"
        )]
        [string] $Name
    )

    begin {
        $InformationPreference = "Continue"
        $ErrorActionPreference = "Stop"
    }

    process {
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
                $Name = Use-InteractiveSelectionMenu -Items $JavaEntryNames
                if (-not $Name) { break }
            }
            else {
                Write-Error -Message "Parameter `"Name`" cannot be an empty string."
            }
        }

        if (-not $Inventory.JavaEntryExists($Name)) {
            Write-Error -Message "Java entry with name `"$Name`" does not exist."
        }

        if ($PSCmdlet.ShouldProcess($Inventory.Path, "Remove Java entry '$Name' from the inventory file")) {
            $Inventory.RemoveJavaEntry($Name)
            $Inventory.SaveFile()
            Write-Information -MessageData "Java entry `"$Name`" removed."
        }
    }
}

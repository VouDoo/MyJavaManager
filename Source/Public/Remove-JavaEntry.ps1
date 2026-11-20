function Remove-JavaEntry {

    <#

    .SYNOPSIS
    Remove a Java entry.

    .DESCRIPTION
    Remove a Java entry from the inventory file.
    Optionally, also remove its Java home directory from the disk.

    .PARAMETER Name
    Name of the Java entry to remove from the inventory file.

    .PARAMETER RemoveDirectory
    Also remove the Java home directory of the entry from the disk.
    The directory is removed before the entry; if it cannot be removed, the entry is kept.
    Nothing is removed if the directory is not a Java home directory or if it is the current JAVA_HOME.
    The directory is kept (only the entry is removed) if other Java entries use it.

    .INPUTS
    None. You cannot pipe objects to Remove-JavaEntry.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Remove-JavaEntry -Name undesired_java

    Remove a Java entry with defined name from the inventory file.

    .EXAMPLE
    PS> Remove-JavaEntry -Name jdk-11.0.13.0 -RemoveDirectory

    Remove a Java entry from the inventory file and its Java home directory from the disk.

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Position = 0,
            HelpMessage = "Name of the Java entry to remove from the inventory file"
        )]
        [string] $Name,

        [Parameter(
            HelpMessage = "Also remove the Java home directory of the entry from the disk"
        )]
        [switch] $RemoveDirectory
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
                $Name = Use-InteractiveSelectionMenu -Items $JavaEntryNames -Header "Select Java entry:"
                if (-not $Name) { return }
            }
            else {
                Write-Error -Message "Parameter `"Name`" cannot be an empty string."
            }
        }

        if (-not $Inventory.JavaEntryExists($Name)) {
            Write-Error -Message "Java entry with name `"$Name`" does not exist."
        }

        if ($RemoveDirectory) {
            $Entry = $Inventory.GetJavaEntry($Name)
            $OtherEntries = @($Inventory.JavaEntries | Where-Object -Property Name -NE $Entry.Name)
            $Removal = Get-JavaHomeRemovalStatus -Path $Entry.Path -OtherEntries $OtherEntries

            switch ($Removal.Status) {
                "Missing" {
                    Write-Warning -Message ("Directory `"{0}`" does not exist. Only the Java entry will be removed." -f $Entry.Path)
                }
                "NotJavaHome" {
                    Write-Error -Message ("Directory `"{0}`" is not a Java home directory. Nothing has been removed. Run without -RemoveDirectory to remove only the Java entry." -f $Entry.Path)
                }
                "InUse" {
                    Write-Error -Message ("Directory `"{0}`" is the current JAVA_HOME. Nothing has been removed. Switch to another Java version first." -f $Entry.Path)
                }
                "Shared" {
                    Write-Warning -Message ("Directory `"{0}`" is also used by Java entries: {1}. Only the Java entry will be removed." -f $Entry.Path, ($Removal.SharedWith -join ", "))
                }
                "Removable" {
                    if ($PSCmdlet.ShouldProcess($Entry.Path, "Remove Java home directory")) {
                        try {
                            Remove-Item -Path $Entry.Path -Recurse -Force -ErrorAction Stop
                        }
                        catch {
                            Write-Error -Message ("Cannot remove directory `"{0}`": {1} The Java entry has been kept." -f $Entry.Path, $_.Exception.Message)
                        }
                        Write-Information -MessageData ("Directory `"{0}`" removed." -f $Entry.Path)
                    }
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($Inventory.Path, "Remove Java entry '$Name' from the inventory file")) {
            $Inventory.RemoveJavaEntry($Name)
            $Inventory.SaveFile()
            Write-Information -MessageData "Java entry `"$Name`" removed."
        }
    }
}

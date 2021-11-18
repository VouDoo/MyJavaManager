class Inventory {
    [string] $Path = (Join-Path -Path $HOME -ChildPath "MyJavaManager.json")
    [string] $Encoding = "UTF8"
    [InventoryEntry[]] $JavaEntries

    [InventoryEntry] GetJavaEntry([string] $Name) {

        <#
        .Description
        Get a Java entry from the inventory.
        #>

        return $this.JavaEntries | Where-Object -Property Name -EQ $Name
    }

    [bool] JavaEntryExists([string] $Name) {

        <#
        .Description
        Test if a Java entry exists in the inventory.
        #>

        return $this.GetJavaEntry($Name).Count -gt 0
    }

    [void] AddJavaEntry([string] $Name, [string] $Path) {

        <#
        .Description
        Add a Java entry to the inventory.
        #>

        $this.JavaEntries += New-Object -TypeName InventoryEntry -ArgumentList $Name, $Path
        Write-Debug -Message "Java entry `"$Name`" has been added to the inventory."
    }

    [void] RemoveJavaEntry([string] $Name) {

        <#
        .Description
        Remove a Java entry from the inventory.
        #>

        $this.JavaEntries = $this.JavaEntries | Where-Object -Property Name -NE $Name
        Write-Debug -Message "Java entry `"$Name`" has been removed from the inventory."
    }

    [bool] FileExists() {

        <#
        .Description
        Test if the inventory file exists.
        #>

        return Test-Path -Path $this.Path -PathType Leaf
    }

    [void] ReadFile() {

        <#
        .Description
        Read Java entries from inventory file.
        #>

        Write-Debug -Message "Start to read the inventory file."

        # Get content of the inventory file
        $GetContentParams = @{
            Path     = $this.Path
            Encoding = $this.Encoding
        }
        try {
            $Content = Get-Content @GetContentParams -ErrorAction Stop
        }
        catch {
            throw "Cannot get content of the inventory file: {0}" -f $_.Exception.Message
        }

        # Convert from JSON
        $Items = $Content | ConvertFrom-Json

        # Re-initialize JavaEntries array
        $this.JavaEntries = @()

        # Add JavaEntry objects to JavaEntries array
        foreach ($Item in $Items) {
            $this.AddJavaEntry($Item.Name, $Item.Path)
        }

        Write-Debug -Message "The inventory file has been read."
    }

    [void] SaveFile() {

        <#
        .Description
        Save inventory in file.
        #>

        Write-Debug -Message "Start to save the inventory file."

        # Set content of the inventory file
        $SetContentParams = @{
            Path     = $this.Path
            Value    = ConvertTo-Json -InputObject @($this.JavaEntries)
            Encoding = $this.Encoding
        }
        try {
            Set-Content @SetContentParams -ErrorAction Stop
        }
        catch {
            throw "Cannot set content of the inventory file: {0}" -f $_.Exception.Message
        }

        Write-Debug -Message "The inventory file has been saved."
    }
}

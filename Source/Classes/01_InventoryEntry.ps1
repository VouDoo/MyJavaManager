class InventoryEntry {
    [string] $Name
    [string] $Path

    InventoryEntry([string] $Name, [string] $Path) {
        $this.Name = $Name
        $this.Path = [PathFormat]::NormalizePath($Path)
    }
}

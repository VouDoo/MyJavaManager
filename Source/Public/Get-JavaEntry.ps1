function Get-JavaEntry {

    <#

    .SYNOPSIS
    Get Java entries.

    .DESCRIPTION
    Get all the Java entries from the inventory file.

    .INPUTS
    None. You cannot pipe objects to Get-JavaEntry.

    .OUTPUTS
    System.Object. Array of Java entry objects.

    .EXAMPLE
    PS> Get-JavaEntry

    Name           Path
    ----           ----
    jdk-8.0.3120.7 C:\Users\user\.java_packages\jdk8u312-b07
    jdk-11.0.13.0  C:\Users\user\.java_packages\jdk-11.0.13+8
    jdk-17.0.1.0   C:\Users\user\.java_packages\jdk-17.0.1+12
    my_jdk         C:\Users\user\.java_packages\jdk-17.0.1+12

    Get all the Java entries from the inventory file.

    #>

    [OutputType([object[]])]
    [CmdletBinding()]
    param ()

    begin {
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

        $Inventory.JavaEntries
    }
}

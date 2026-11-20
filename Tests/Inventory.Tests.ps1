#Requires -Modules @{ ModuleName = "Pester"; ModuleVersion = "5.0.0" }

BeforeAll {
    # Load the classes directly from the sources (in the same order as the build),
    # so the tests run without building or importing the module.
    $ClassesDirectory = Join-Path -Path $PSScriptRoot -ChildPath "../Source/Classes"
    Get-ChildItem -Path $ClassesDirectory -Filter "*.ps1" | Sort-Object -Property Name | ForEach-Object -Process {
        . $_.FullName
    }

    function New-TestInventory {
        # Inventory whose file lives in the Pester test drive instead of $HOME
        $Inventory = [Inventory]::new()
        $Inventory.Path = Join-Path -Path $TestDrive -ChildPath "MyJavaManager.json"
        $Inventory
    }
}

Describe "Inventory" {

    BeforeEach {
        $Inventory = New-TestInventory
        $Jdk11Path = Join-Path -Path $TestDrive -ChildPath "jdk-11"
        $Jdk17Path = Join-Path -Path $TestDrive -ChildPath "jdk-17"
    }

    AfterEach {
        Remove-Item -Path $Inventory.Path -Force -ErrorAction SilentlyContinue
    }

    Context "Default values" {

        It "Uses MyJavaManager.json in the home directory by default" {
            [Inventory]::new().Path | Should -Be (Join-Path -Path $HOME -ChildPath "MyJavaManager.json")
        }

        It "Has no Java entries" {
            [Inventory]::new().JavaEntries | Should -BeNullOrEmpty
        }
    }

    Context "AddJavaEntry" {

        It "Adds an entry with the given name and path" {
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)

            $Inventory.JavaEntries | Should -HaveCount 1
            $Inventory.JavaEntries[0].Name | Should -Be "jdk-17"
            $Inventory.JavaEntries[0].Path | Should -Be $Jdk17Path
        }

        It "Normalizes the path (removes the trailing directory separator)" {
            $Inventory.AddJavaEntry("jdk-17", ($Jdk17Path + [System.IO.Path]::DirectorySeparatorChar))

            $Inventory.JavaEntries[0].Path | Should -Be $Jdk17Path
        }

        It "Keeps entries in insertion order" {
            $Inventory.AddJavaEntry("jdk-11", $Jdk11Path)
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)

            $Inventory.JavaEntries.Name | Should -Be @("jdk-11", "jdk-17")
        }
    }

    Context "GetJavaEntry and JavaEntryExists" {

        BeforeEach {
            $Inventory.AddJavaEntry("jdk-11", $Jdk11Path)
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)
        }

        It "Gets an entry by name" {
            $Entry = $Inventory.GetJavaEntry("jdk-17")

            $Entry.Name | Should -Be "jdk-17"
            $Entry.Path | Should -Be $Jdk17Path
        }

        It "Matches names case-insensitively" {
            $Inventory.GetJavaEntry("JDK-17").Name | Should -Be "jdk-17"
            $Inventory.JavaEntryExists("JDK-17") | Should -BeTrue
        }

        It "Returns null for an unknown name" {
            $Inventory.GetJavaEntry("unknown") | Should -BeNullOrEmpty
        }

        It "Tells whether an entry exists" {
            $Inventory.JavaEntryExists("jdk-11") | Should -BeTrue
            $Inventory.JavaEntryExists("unknown") | Should -BeFalse
        }

        It "Tells that no entry exists in an empty inventory" {
            (New-TestInventory).JavaEntryExists("jdk-11") | Should -BeFalse
        }
    }

    Context "RemoveJavaEntry" {

        BeforeEach {
            $Inventory.AddJavaEntry("jdk-11", $Jdk11Path)
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)
        }

        It "Removes only the entry with the given name" {
            $Inventory.RemoveJavaEntry("jdk-11")

            $Inventory.JavaEntries | Should -HaveCount 1
            $Inventory.JavaEntries[0].Name | Should -Be "jdk-17"
        }

        It "Leaves an empty array (not null) when the last entry is removed" {
            $Inventory.RemoveJavaEntry("jdk-11")
            $Inventory.RemoveJavaEntry("jdk-17")

            $null -eq $Inventory.JavaEntries | Should -BeFalse
            $Inventory.JavaEntries.Count | Should -Be 0
        }

        It "Does nothing for an unknown name" {
            $Inventory.RemoveJavaEntry("unknown")

            $Inventory.JavaEntries | Should -HaveCount 2
        }
    }

    Context "FileExists" {

        It "Returns false when the inventory file does not exist" {
            $Inventory.FileExists() | Should -BeFalse
        }

        It "Returns true once the inventory file has been saved" {
            $Inventory.SaveFile()

            $Inventory.FileExists() | Should -BeTrue
        }
    }

    Context "SaveFile and ReadFile" {

        It "Round-trips several entries" {
            $Inventory.AddJavaEntry("jdk-11", $Jdk11Path)
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)
            $Inventory.SaveFile()

            $Loaded = New-TestInventory
            $Loaded.ReadFile()

            $Loaded.JavaEntries.Name | Should -Be @("jdk-11", "jdk-17")
            $Loaded.JavaEntries.Path | Should -Be @($Jdk11Path, $Jdk17Path)
        }

        It "Saves a single entry as a JSON array" {
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)
            $Inventory.SaveFile()

            (Get-Content -Path $Inventory.Path -Raw).Trim() | Should -Match "^\[[\s\S]*\]$"

            $Loaded = New-TestInventory
            $Loaded.ReadFile()
            $Loaded.JavaEntries | Should -HaveCount 1
            $Loaded.JavaEntries[0].Name | Should -Be "jdk-17"
        }

        It "Saves an empty inventory as an empty JSON array" {
            $Inventory.SaveFile()

            (Get-Content -Path $Inventory.Path -Raw).Trim() | Should -Be "[]"
        }

        It "Can be read back after the last entry has been removed" {
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)
            $Inventory.SaveFile()
            $Inventory.RemoveJavaEntry("jdk-17")
            $Inventory.SaveFile()

            (Get-Content -Path $Inventory.Path -Raw).Trim() | Should -Be "[]"

            $Loaded = New-TestInventory
            { $Loaded.ReadFile() } | Should -Not -Throw
            $Loaded.JavaEntries | Should -BeNullOrEmpty
        }

        It "Replaces the entries in memory with the ones from the file" {
            $Inventory.AddJavaEntry("jdk-17", $Jdk17Path)
            $Inventory.SaveFile()
            $Inventory.AddJavaEntry("jdk-11", $Jdk11Path)

            $Inventory.ReadFile()

            $Inventory.JavaEntries | Should -HaveCount 1
            $Inventory.JavaEntries[0].Name | Should -Be "jdk-17"
        }

        It "Reads a file corrupted as [null] by older versions" {
            Set-Content -Path $Inventory.Path -Value "[`n  null`n]"

            { $Inventory.ReadFile() } | Should -Not -Throw
            $Inventory.JavaEntries | Should -BeNullOrEmpty
        }

        It "Skips null and incomplete items" {
            $Json = @(
                "[",
                "  null,",
                "  { `"Name`": `"no-path`" },",
                "  { `"Path`": `"/no/name`" },",
                ("  {{ `"Name`": `"jdk-17`", `"Path`": {0} }}" -f (ConvertTo-Json -InputObject $Jdk17Path)),
                "]"
            ) -join "`n"
            Set-Content -Path $Inventory.Path -Value $Json

            $Inventory.ReadFile()

            $Inventory.JavaEntries | Should -HaveCount 1
            $Inventory.JavaEntries[0].Name | Should -Be "jdk-17"
        }

        It "Throws a clear error when the file does not exist" {
            { $Inventory.ReadFile() } | Should -Throw "Cannot get content of the inventory file*"
        }
    }
}

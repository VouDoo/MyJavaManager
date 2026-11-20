#Requires -Modules @{ ModuleName = "Pester"; ModuleVersion = "5.0.0" }

BeforeAll {
    # Load the classes and the functions under test directly from the sources
    $SourceDirectory = Join-Path -Path $PSScriptRoot -ChildPath "../Source"
    Get-ChildItem -Path (Join-Path -Path $SourceDirectory -ChildPath "Classes") -Filter "*.ps1" | Sort-Object -Property Name | ForEach-Object -Process {
        . $_.FullName
    }
    . (Join-Path -Path $SourceDirectory -ChildPath "Private/Java/Test-JavaHomeDirectory.ps1")
    . (Join-Path -Path $SourceDirectory -ChildPath "Private/Java/Get-JavaHomeRemovalStatus.ps1")

    function New-FakeJavaHome([string] $Name) {
        # Directory that looks like a Java home directory (contains bin\java.exe)
        $JavaHome = Join-Path -Path $TestDrive -ChildPath $Name
        New-Item -Path (Join-Path -Path $JavaHome -ChildPath "bin") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $JavaHome -ChildPath "bin/java.exe") -ItemType File -Force | Out-Null
        $JavaHome
    }
}

Describe "Get-JavaHomeRemovalStatus" {

    BeforeEach {
        $SavedJavaHome = $env:JAVA_HOME
        $env:JAVA_HOME = $null
        $Jdk17Path = New-FakeJavaHome -Name "jdk-17"
        $Jdk11Path = New-FakeJavaHome -Name "jdk-11"
    }

    AfterEach {
        $env:JAVA_HOME = $SavedJavaHome
    }

    It "Returns Missing when the directory does not exist" {
        $Result = Get-JavaHomeRemovalStatus -Path (Join-Path -Path $TestDrive -ChildPath "does-not-exist")

        $Result.Status | Should -Be "Missing"
    }

    It "Returns NotJavaHome when the directory has no bin/java.exe" {
        $NotJavaHome = Join-Path -Path $TestDrive -ChildPath "not-java"
        New-Item -Path $NotJavaHome -ItemType Directory | Out-Null

        $Result = Get-JavaHomeRemovalStatus -Path $NotJavaHome

        $Result.Status | Should -Be "NotJavaHome"
    }

    It "Returns Removable when no other entry uses the directory and it is not JAVA_HOME" {
        $OtherEntries = @([InventoryEntry]::new("jdk-11", $Jdk11Path))

        $Result = Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries $OtherEntries

        $Result.Status | Should -Be "Removable"
        $Result.SharedWith | Should -BeNullOrEmpty
    }

    It "Returns Removable without other entries" {
        (Get-JavaHomeRemovalStatus -Path $Jdk17Path).Status | Should -Be "Removable"
        (Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries $null).Status | Should -Be "Removable"
        (Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries @()).Status | Should -Be "Removable"
    }

    It "Returns Shared with the names of the other entries using the directory" {
        $OtherEntries = @(
            [InventoryEntry]::new("my_jdk", $Jdk17Path),
            [InventoryEntry]::new("jdk-11", $Jdk11Path),
            [InventoryEntry]::new("another_jdk", $Jdk17Path)
        )

        $Result = Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries $OtherEntries

        $Result.Status | Should -Be "Shared"
        $Result.SharedWith | Should -Be @("my_jdk", "another_jdk")
    }

    It "Compares entry paths ignoring trailing separators and case" {
        $OtherEntries = @([PSCustomObject]@{
                Name = "my_jdk"
                Path = $Jdk17Path.ToUpperInvariant() + [System.IO.Path]::DirectorySeparatorChar
            })

        $Result = Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries $OtherEntries

        $Result.Status | Should -Be "Shared"
    }

    It "Ignores null other entries" {
        $OtherEntries = @($null, [InventoryEntry]::new("jdk-11", $Jdk11Path))

        (Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries $OtherEntries).Status | Should -Be "Removable"
    }

    It "Returns InUse when the directory is the current JAVA_HOME" {
        $env:JAVA_HOME = $Jdk17Path + [System.IO.Path]::DirectorySeparatorChar

        (Get-JavaHomeRemovalStatus -Path $Jdk17Path).Status | Should -Be "InUse"
    }

    It "Returns InUse rather than Shared when both apply" {
        $env:JAVA_HOME = $Jdk17Path
        $OtherEntries = @([InventoryEntry]::new("my_jdk", $Jdk17Path))

        (Get-JavaHomeRemovalStatus -Path $Jdk17Path -OtherEntries $OtherEntries).Status | Should -Be "InUse"
    }

    It "Does not return InUse when JAVA_HOME is another directory" {
        $env:JAVA_HOME = $Jdk11Path

        (Get-JavaHomeRemovalStatus -Path $Jdk17Path).Status | Should -Be "Removable"
    }
}

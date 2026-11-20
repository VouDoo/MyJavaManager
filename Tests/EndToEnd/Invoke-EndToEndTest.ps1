<#

.SYNOPSIS
End-to-end tests of MyJavaManager on Windows.

.DESCRIPTION
Run the commands of the module for real: download JDKs from Adoptium, change JAVA_HOME and the Path
in the User, Process and Machine scopes, and remove directories.
These tests change the system, so they are meant for disposable CI machines (GitHub Actions) only.

.PARAMETER ModulePath
Path to the manifest (.psd1) of the built module.

.PARAMETER Arm64Only
Only check that the downloaded Java package matches an ARM64 system.

.PARAMETER Force
Run the tests outside GitHub Actions anyway.

.EXAMPLE
PS> .\Tests\EndToEnd\Invoke-EndToEndTest.ps1 -ModulePath .\Out\MyJavaManager\0.3.0\MyJavaManager.psd1

Run the end-to-end tests against the built module (in GitHub Actions).

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $ModulePath,

    [switch] $Arm64Only,

    [switch] $Force
)

$ErrorActionPreference = "Stop"

if (-not $Force -and $env:GITHUB_ACTIONS -ne "true") {
    throw "These tests download JDKs and change JAVA_HOME and the Path of the system. Run them in CI only (or use -Force)."
}

Import-Module -Name $ModulePath -Force

$InventoryFile = Join-Path -Path $HOME -ChildPath "MyJavaManager.json"
$PackagesDirectory = Join-Path -Path $HOME -ChildPath ".java_packages"
$Failures = 0

#region Helpers
function Write-Step([string] $Title) {
    Write-Host "`n=== $Title" -ForegroundColor Cyan
}

function Assert-True([bool] $Condition, [string] $Message) {
    if ($Condition) {
        Write-Host "[PASS] $Message" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] $Message" -ForegroundColor Red
        $script:Failures++
    }
}

function Assert-Throw([scriptblock] $ScriptBlock, [string] $ExpectedMessage, [string] $Message) {
    try {
        & $ScriptBlock
        Assert-True $false "$Message (no error)"
    }
    catch {
        Assert-True ($_.Exception.Message -like $ExpectedMessage) "$Message (error: $($_.Exception.Message))"
    }
}

function Get-InventoryEntry {
    # Read the inventory file directly, without the module
    if (-not (Test-Path -Path $InventoryFile)) {
        return
    }
    $Items = Get-Content -Path $InventoryFile -Raw | ConvertFrom-Json
    foreach ($Item in $Items) {
        if ($Item) { $Item }
    }
}

function Get-RegistryPathEntry([string] $Target) {
    # Raw value of the Path environment variable (without expanding %JAVA_HOME%)
    $Key = if ($Target -eq "Machine") {
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    }
    else {
        "HKCU:\Environment"
    }
    (Get-Item -Path $Key).GetValue("Path", "", "DoNotExpandEnvironmentNames") -split ";"
}

function Get-JavaVersionOutput {
    # java -version writes to stderr, which must not stop the script
    $ErrorActionPreference = "Continue"
    & java -version 2>&1 | Out-String
}
#endregion Helpers

Write-Step "Initial state"
Write-Host ("PowerShell {0} ({1})" -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition)
Write-Host ("System architecture: {0}" -f [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "Machine"))
Write-Host "JAVA_HOME (Process): $env:JAVA_HOME"
Assert-True (-not (Test-Path -Path $InventoryFile)) "No inventory file yet"

if ($Arm64Only) {
    Write-Step "Download Java 21 on ARM64"
    Invoke-DownloadJavaPackage -Version 21
    $Jdk21 = @(Get-InventoryEntry)[0]
    $Release = Get-Content -Path (Join-Path -Path $Jdk21.Path -ChildPath "release") -Raw
    Assert-True ($Release -match 'OS_ARCH="aarch64"') "Downloaded JDK is an ARM64 build"

    Switch-JavaVersion -Name $Jdk21.Name -Target Process
    Assert-True ((Get-JavaVersionOutput) -match 'version "21') "java -version runs Java 21"
}
else {
    Write-Step "Download Java 21"
    Invoke-DownloadJavaPackage -Version 21
    $Jdk21 = @(Get-InventoryEntry) | Where-Object -FilterScript { (Split-Path -Path $_.Path -Leaf) -like "jdk-21*" }
    Assert-True ($null -ne $Jdk21) "Java 21 entry added to the inventory"
    Assert-True ($Jdk21.Path -like "$PackagesDirectory\*") "Java 21 installed in .java_packages ($($Jdk21.Path))"
    Assert-True (Test-Path -Path (Join-Path -Path $Jdk21.Path -ChildPath "bin\java.exe")) "Java 21 has bin\java.exe"
    $Release = Get-Content -Path (Join-Path -Path $Jdk21.Path -ChildPath "release") -Raw
    Assert-True ($Release -notmatch 'OS_ARCH="aarch64"') "Downloaded JDK is an x64 build"

    Write-Step "Download the default version"
    $Lts = (Invoke-RestMethod -Uri "https://api.adoptium.net/v3/info/available_releases").most_recent_lts
    if ([Environment]::UserInteractive) {
        Write-Host "Session is interactive (no default without the menu): downloading Java $Lts explicitly."
        Invoke-DownloadJavaPackage -Version $Lts
    }
    else {
        Invoke-DownloadJavaPackage
    }
    $JdkLts = @(Get-InventoryEntry) | Where-Object -FilterScript { (Split-Path -Path $_.Path -Leaf) -like "jdk-$Lts*" }
    Assert-True ($null -ne $JdkLts) "Latest LTS (Java $Lts) downloaded by default"

    Write-Step "Get-JavaEntry"
    Assert-True (@(Get-JavaEntry).Count -eq 2) "Get-JavaEntry returns the 2 entries"

    Write-Step "Add-JavaEntry with a relative path"
    Push-Location -Path $PackagesDirectory
    try {
        Add-JavaEntry -Path (".\" + (Split-Path -Path $Jdk21.Path -Leaf)) -CustomName "relative-21"
    }
    finally {
        Pop-Location
    }
    $Relative = @(Get-InventoryEntry) | Where-Object -Property Name -EQ "relative-21"
    Assert-True ($Relative.Path -eq $Jdk21.Path) "Relative path resolved against the PowerShell location ($($Relative.Path))"

    Write-Step "Switch-JavaVersion -WhatIf"
    $PathBefore = $env:Path
    $JavaHomeBefore = $env:JAVA_HOME
    $UserJavaHomeBefore = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
    Switch-JavaVersion -Name $Jdk21.Name -WhatIf
    Assert-True ($env:Path -eq $PathBefore) "Session Path unchanged"
    Assert-True ($env:JAVA_HOME -eq $JavaHomeBefore) "Session JAVA_HOME unchanged"
    Assert-True ([System.Environment]::GetEnvironmentVariable("JAVA_HOME", "User") -eq $UserJavaHomeBefore) "User JAVA_HOME unchanged"

    Write-Step "Switch-JavaVersion to Java 21 (User scope)"
    $env:Path = "C:\session-only-entry;" + $env:Path
    Switch-JavaVersion -Name $Jdk21.Name
    $Entries = $env:Path -split ";"
    Assert-True ([System.Environment]::GetEnvironmentVariable("JAVA_HOME", "User") -eq $Jdk21.Path) "User JAVA_HOME set"
    Assert-True ((Get-RegistryPathEntry -Target User) -contains "%JAVA_HOME%\bin") "%JAVA_HOME%\bin in the User Path (registry)"
    Assert-True ($env:JAVA_HOME -eq $Jdk21.Path) "Session JAVA_HOME set"
    Assert-True ($Entries[0] -eq "$($Jdk21.Path)\bin") "Java 21 bin first in the session Path"
    Assert-True ($Entries -contains "C:\session-only-entry") "Session-only Path entry kept"
    Assert-True ((Get-Command -Name java).Source -eq "$($Jdk21.Path)\bin\java.exe") "java resolves to Java 21"
    Assert-True ((Get-JavaVersionOutput) -match 'version "21') "java -version runs Java 21"

    Write-Step "Switch-JavaVersion to Java $Lts (User scope)"
    Switch-JavaVersion -Name $JdkLts.Name
    $Entries = $env:Path -split ";"
    Assert-True ($Entries[0] -eq "$($JdkLts.Path)\bin") "Java $Lts bin first in the session Path"
    Assert-True ($Entries -notcontains "$($Jdk21.Path)\bin") "Java 21 bin removed from the session Path"
    Assert-True ($Entries -contains "C:\session-only-entry") "Session-only Path entry still kept"
    Assert-True (@(Get-RegistryPathEntry -Target User | Where-Object -FilterScript { $_ -eq "%JAVA_HOME%\bin" }).Count -eq 1) "%JAVA_HOME%\bin only once in the User Path"
    Assert-True ((Get-JavaVersionOutput) -match "version `"$Lts") "java -version runs Java $Lts"

    Write-Step "Switch-JavaVersion to Java 21 (Process scope)"
    Switch-JavaVersion -Name $Jdk21.Name -Target Process
    Assert-True ($env:JAVA_HOME -eq $Jdk21.Path) "Session JAVA_HOME set to Java 21"
    Assert-True ([System.Environment]::GetEnvironmentVariable("JAVA_HOME", "User") -eq $JdkLts.Path) "User JAVA_HOME still Java $Lts"
    Assert-True ((Get-JavaVersionOutput) -match 'version "21') "java -version runs Java 21"

    Write-Step "Remove-JavaEntry -RemoveDirectory"
    Assert-Throw { Remove-JavaEntry -Name $Jdk21.Name -RemoveDirectory } "*is the current JAVA_HOME*" "Refuses to remove the current JAVA_HOME"
    Assert-True (Test-Path -Path $Jdk21.Path) "Java 21 directory kept"
    Switch-JavaVersion -Name $JdkLts.Name -Target Process
    Remove-JavaEntry -Name "relative-21" -RemoveDirectory
    Assert-True (Test-Path -Path $Jdk21.Path) "Directory shared with another entry kept"
    Assert-True (-not (@(Get-InventoryEntry) | Where-Object -Property Name -EQ "relative-21")) "Entry with shared directory removed"
    Remove-JavaEntry -Name $Jdk21.Name -RemoveDirectory
    Assert-True (-not (Test-Path -Path $Jdk21.Path)) "Java 21 directory removed"
    Assert-True (-not (@(Get-InventoryEntry) | Where-Object -Property Name -EQ $Jdk21.Name)) "Java 21 entry removed"

    Write-Step "Remove the last Java entry"
    Remove-JavaEntry -Name $JdkLts.Name
    Assert-True (@(Get-InventoryEntry).Count -eq 0) "Inventory is empty"
    Assert-True ((Get-Content -Path $InventoryFile -Raw) -notmatch "null") "Inventory file has no null item"
    Assert-Throw { Get-JavaEntry } "*no Java entry*" "Get-JavaEntry reports the empty inventory"
    Add-JavaEntry -Path $JdkLts.Path -CustomName "lts-again"
    Assert-True (@(Get-InventoryEntry).Count -eq 1) "A Java entry can be added again"

    Write-Step "Switch-JavaVersion to Java $Lts (Machine scope)"
    Switch-JavaVersion -Name "lts-again" -Target Machine
    Assert-True ([System.Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine") -eq $JdkLts.Path) "Machine JAVA_HOME set"
    Assert-True ((Get-RegistryPathEntry -Target Machine) -contains "%JAVA_HOME%\bin") "%JAVA_HOME%\bin in the Machine Path (registry)"
    Assert-True (-not (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path")) "No Path subkey created under the Environment key"
}

Write-Host ""
if ($Failures -gt 0) {
    Write-Host "$Failures check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "All checks passed." -ForegroundColor Green

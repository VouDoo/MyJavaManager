# MyJavaManager

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/MyJavaManager)](https://www.powershellgallery.com/packages/MyJavaManager)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/MyJavaManager)](https://www.powershellgallery.com/packages/MyJavaManager)
[![CI](https://github.com/VouDoo/MyJavaManager/actions/workflows/ci.yml/badge.svg)](https://github.com/VouDoo/MyJavaManager/actions/workflows/ci.yml)

MyJavaManager is a PowerShell module to install, track and switch between Java versions on Windows.

- **Download Java** from [Adoptium](https://adoptium.net/) (Eclipse Temurin JDK), for the architecture of your system (x64 or ARM64)
- **Keep track** of your Java versions in an inventory (JSON file), including the ones you installed yourself
- **Switch between Java versions** in one command: `JAVA_HOME` and `Path` are updated, in the current console too
- **Remove** a Java version, and optionally its directory, safely

## Quick start

```powershell
Install-Module -Name MyJavaManager       # Install the module from PowerShell Gallery
Invoke-DownloadJavaPackage -Version 21   # Download Java 21 and add it to the inventory
Get-JavaEntry                            # List the Java versions of the inventory
Switch-JavaVersion                       # Pick the Java version to use from a menu
java -version                            # Ready to use, right away
```

---

Table of contents:

- [MyJavaManager](#myjavamanager)
  - [Quick start](#quick-start)
  - [Installation](#installation)
    - [Install from PowerShell Gallery](#install-from-powershell-gallery)
    - [Get released versions](#get-released-versions)
    - [Build from Source](#build-from-source)
  - [Usage](#usage)
    - [Import the module](#import-the-module)
    - [Download Java](#download-java)
    - [Add an existing Java installation](#add-an-existing-java-installation)
    - [Switch Java version](#switch-java-version)
    - [Remove a Java version](#remove-a-java-version)
    - [Commands](#commands)
    - [Get help](#get-help)
  - [Contributing](#contributing)
  - [License](#license)
  - [Support](#support)

---

## Installation

The module is **Windows-only** (it relies on the Windows Registry and Windows APIs).

It supports the following PowerShell versions:

- Windows PowerShell 5.1
- PowerShell 6 and later, on Windows

Get the latest version of PowerShell from [the official PowerShell repository](https://github.com/PowerShell/PowerShell/releases).

### Install from PowerShell Gallery

The module is published on PowerShell Gallery.
See <https://www.powershellgallery.com/packages/MyJavaManager>.

To install it, run:

```powershell
Install-Module -Name MyJavaManager -Repository PSGallery
```

_On PowerShell 7.4 or later, you can also run `Install-PSResource -Name MyJavaManager`._

### Get released versions

Download `MyJavaManager.zip` from [the "Releases" page](https://github.com/VouDoo/MyJavaManager/releases).
Extract it to your user modules directory:

- Windows PowerShell 5.1: `~\Documents\WindowsPowerShell\Modules\`
- PowerShell 6 and later: `~\Documents\PowerShell\Modules\`

### Build from Source

1. Unblock downloaded scripts _(optional)_

    ```powershell
    Get-ChildItem -Filter *.ps1 | Unblock-File
    ```

2. Build the module

    ```powershell
    .\build.ps1 Build -Bootstrap
    ```

3. Remove any old versions of the module

    ```powershell
    $ModulesDirectory = $env:PSModulePath.Split([System.IO.Path]::PathSeparator)[0]
    Remove-Item (Join-Path $ModulesDirectory "MyJavaManager") -Recurse -Force -ErrorAction SilentlyContinue
    ```

4. Install the freshly built module

    ```powershell
    Copy-Item ".\Out\MyJavaManager" $ModulesDirectory -Recurse
    ```

---

## Usage

### Import the module

1. Import the module

    ```powershell
    Import-Module -Name MyJavaManager
    ```

2. Get the available commands

    ```powershell
    Get-Command -Module MyJavaManager
    ```

The fastest way to use the module is to import it from your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) (run `$PROFILE` to get its path).
Then, each time you will open your PowerShell console, the module will be automatically imported.

Your Java versions are stored in the inventory file `~\MyJavaManager.json`.

### Download Java

To download and install a Java package from Adoptium, use `Invoke-DownloadJavaPackage`.

```powershell
Invoke-DownloadJavaPackage -Version 21
```

- Without `-Version`, a menu lets you pick the version (LTS versions are marked, e.g. `21 (LTS)`).
  In a non-interactive session, the latest LTS (Long-Term Support) version is downloaded.
- The package is installed in `~\.java_packages`, and an entry is added to the inventory.
- The package matches the architecture of your system (x64 or ARM64).
  Adoptium provides Windows ARM64 packages for some Java versions only.

### Add an existing Java installation

To add a Java version that you installed yourself, use `Add-JavaEntry` with the path to its Java home directory.

```powershell
Add-JavaEntry -Path "C:\Program Files\Java\jdk-17"
Add-JavaEntry -Path "C:\Program Files\Java\jdk-17" -CustomName MyJava17
```

The entry is named after the Java version (e.g. `jdk-17.0.1.0`), unless you give a custom name.

### Switch Java version

To use another Java version, use `Switch-JavaVersion`.

```powershell
Switch-JavaVersion                    # Pick the Java version from a menu
Switch-JavaVersion -Name MyJava17     # Use a Java version of the inventory
Switch-JavaVersion -Path "C:\path\to\java_home_directory"   # Use any Java home directory
```

It sets the `JAVA_HOME` environment variable and adds `%JAVA_HOME%\bin` to the `Path`.
The current console is updated too, so you can use the new version right away.

The `-Target` parameter defines where the change is saved:

| Target    | Description |
|:---------:| :---------- |
| `User`    | For your user: the current console and new ones. **(Default)** |
| `Machine` | For all users: the current console and new ones. Requires administrator rights. |
| `Process` | For the current console only. |

### Remove a Java version

To remove a Java version from the inventory, use `Remove-JavaEntry`.

```powershell
Remove-JavaEntry -Name MyJava17
Remove-JavaEntry -Name jdk-11.0.13.0 -RemoveDirectory   # Also remove its directory from the disk
```

With `-RemoveDirectory`, nothing is removed if the directory is not a Java home directory or if it is the current `JAVA_HOME`.
If other entries use the same directory, only the entry is removed.

### Commands

| Command | Description |
| :------ | :---------- |
| `Invoke-DownloadJavaPackage` | Downloads and installs a Java package from Adoptium, and adds it to the inventory. |
| `Add-JavaEntry` | Adds an existing Java installation to the inventory. |
| `Get-JavaEntry` | Gets the Java versions of the inventory. |
| `Switch-JavaVersion` | Switches the Java version in use (`JAVA_HOME` and `Path`). |
| `Remove-JavaEntry` | Removes a Java version from the inventory, and optionally its directory. |

_Every command that changes something supports `-WhatIf` and `-Confirm`._

### Get help

Read help files in [docs/cmdlet-help](docs/cmdlet-help).

You can also use [the `Get-Help` Cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) to obtain more information about a command.

---

## Contributing

To build the module and run the tests (PSScriptAnalyzer and Pester), run:

```powershell
.\build.ps1 Test -Bootstrap
```

Read [docs/development](docs/development) for the docstrings, versioning and publishing guidelines.

## License

MyJavaManager is released under the terms of the MIT license.
See [LICENSE](LICENSE) or <https://opensource.org/licenses/MIT>.

## Support

If you have any bug reports, log them on [the issue tracker](https://github.com/VouDoo/MyJavaManager/issues).

If you have some suggestions, please don't hesitate to contact me (find email on [my GitHub profile](https://github.com/VouDoo)).

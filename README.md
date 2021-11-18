# MyJavaManager

MyJavaManager is a PowerShell module that helps you to manage versions of Java on your system.

Available features:

- Keep in track Java versions in an inventory (i.e. JSON file)
- Easily switch between java versions (set the `JAVA_HOME` environment variable)
- Automatically download and install Java package from <https://adoptium.net/> (previously <https://adoptopenjdk.net/>)

## License

MyJavaManager is released under the terms of the MIT license.

See [LICENSE](LICENSE) for more information or see <https://opensource.org/licenses/MIT>.

---

## Installation

To install the PowerShell module, follow one of these methods:

- [Install from PS Gallery](#install-from-ps-gallery)
- [Get released versions](#get-released-versions)
- [Build from Source](#build-from-source)

The module supports the following PowerShell versions:

- PowerShell Desktop 5.1
- PowerShell Core 6 and later

Get the latest version of PowerShell from [the official PowerShell repository](https://github.com/PowerShell/PowerShell/releases).

### Install from PS Gallery

The module is published on PowerShell Gallery.

See <https://www.powershellgallery.com/packages/MyJavaManager>.

To install it, run:

```powershell
Install-Module -Name MyJavaManager -Repository PSGallery
```

### Get released versions

Download `MyJavaManager.zip` from [the "Releases" page](https://github.com/VouDoo/MyJavaManager/releases).

Extract it in `C:\Users\<your_user>\Documents\PowerShell\Modules\`.

### Build from Source

1. Unblock downloaded scripts _(optional)_

    ```powershell
    Get-ChildItem -Filter *.ps1 | Unblock-File
    ```

2. Build the module

    ```powershell
    .\build.ps1 build -Bootstrap
    ```

3. Remove any old versions of the module

    ```powershell
    Remove-Item "$HOME\Documents\PowerShell\Modules\MyJavaManager" -Force
    ```

4. Install the freshly built module

    ```powershell
    Copy-Item ".\Out\MyJavaManager" "$HOME\Documents\PowerShell\Modules\" -Recurse
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

The fastest way to use the module is to import it from your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).
Then, each time you will open your PowerShell console, the module will be automatically imported.

### Get help

Read help files in [docs/cmdlet-help](docs/cmdlet-help).

You can also use [the `Get-Help` Cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) to obtain more information about a command.

---

## Support

If you have any bug reports, log them on [the issue tracker](https://github.com/VouDoo/MyJavaManager/issues).

If you have some suggestions, please don't hesitate to contact me (find email on [my GitHub profile](https://github.com/VouDoo)).

# Changelog

All notable changes to MyJavaManager is documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- The module is now explicitly Windows-only: importing it on Linux or macOS fails with a clear error, and the README and gallery tags state it

### Fixed

- `Switch-JavaVersion` failed the first time `%JAVA_HOME%\bin` was added to the Path (call to non-existent `Update-EnvPathProcess`)
- `Switch-JavaVersion -Target Machine` wrote the Path value to a wrong registry subkey
- Relative paths given to `Add-JavaEntry` and `Switch-JavaVersion -Path` were resolved against the process working directory instead of the PowerShell location
- Cancelling an interactive menu with ESC used `break`, which could stop the caller's loop or script
- `Send-WMSettingChangeMessage` used the `[uint]` type accelerator, which is not available in Windows PowerShell 5.1
- Removing the last Java entry could save the inventory as `[null]`, which made every following command fail on Windows PowerShell 5.1 (such files are now read correctly)
- `Invoke-DownloadJavaPackage` failed with an obscure error when Adoptium has no Windows x64 JDK package for the requested version

## [0.1.0]

Initial release of the module

# Changelog

All notable changes to MyJavaManager is documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Windows ARM64 support in `Invoke-DownloadJavaPackage`: the package matching the architecture of the system is downloaded (Adoptium provides Windows ARM64 packages for some Java versions only)

### Changed

- When run non-interactively without `-Version`, `Invoke-DownloadJavaPackage` downloads the latest LTS (Long-Term Support) version instead of the latest version
- The interactive menu of `Invoke-DownloadJavaPackage` marks LTS versions

## [0.2.0] - 2026-11-20

### Added

- `RemoveDirectory` parameter on `Remove-JavaEntry` to also remove the Java home directory from the disk (not removed if it is the current `JAVA_HOME`, not a Java home directory, or used by other entries)

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
- `Switch-JavaVersion` updated the Path of the current session with substring replacements, which could alter unrelated entries, drop entries added in the session, or leave the new Java out of the Path; the new Java `bin` directory is now put first and only previous Java `bin` entries are removed
- `Switch-JavaVersion -WhatIf` still modified the Path of the current session

## [0.1.0] - 2021-11-18

Initial release of the module

[Unreleased]: https://github.com/VouDoo/MyJavaManager/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/VouDoo/MyJavaManager/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/VouDoo/MyJavaManager/releases/tag/v0.1.0

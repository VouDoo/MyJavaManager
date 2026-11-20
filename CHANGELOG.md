# Changelog

All notable changes to MyJavaManager is documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `Switch-JavaVersion` failed the first time `%JAVA_HOME%\bin` was added to the Path (call to non-existent `Update-EnvPathProcess`)
- `Switch-JavaVersion -Target Machine` wrote the Path value to a wrong registry subkey
- Relative paths given to `Add-JavaEntry` and `Switch-JavaVersion -Path` were resolved against the process working directory instead of the PowerShell location

## [0.1.0]

Initial release of the module

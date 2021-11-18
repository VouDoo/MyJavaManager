$ProjectRoot = $PSScriptRoot

$ModuleName = "MyJavaManager"
$ModuleVersion = "0.1.0"

$Source = Join-Path -Path $ProjectRoot -ChildPath "Source"
$Tests = Join-Path -Path $ProjectRoot -ChildPath "Tests"
$Out = Join-Path -Path $ProjectRoot -ChildPath "Out\$ModuleName\$ModuleVersion"
$Docs = Join-Path -Path $ProjectRoot -ChildPath "docs"

@{
    # Project
    ProjectRoot                 = $ProjectRoot
    # Module
    ModuleName                  = $ModuleName
    ModuleVersion               = $ModuleVersion
    # Source
    Source                      = $Source
    SourceHeader                = Get-Item -Path "$Source\$ModuleName.Header.ps1"
    #SourceEnum                  = Get-ChildItem -Path "$Source\Enum" -Include "*.ps1" -Recurse -File
    SourceClasses               = Get-ChildItem -Path "$Source\Classes" -Include "*.ps1" -Recurse -File | Sort-Object Name
    SourcePrivateFunctions      = Get-ChildItem -Path "$Source\Private" -Filter "*.ps1" -Recurse -File
    SourcePublicFunctions       = Get-ChildItem -Path "$Source\Public" -Filter "*.ps1" -Recurse -File
    #SourceDataFiles             = Get-ChildItem -Path "$Source\Data"
    SourceManifest              = Join-Path -Path $Source -ChildPath "$ModuleName.psd1"
    # Tests
    Tests                       = $Tests
    TestsScriptAnalyzerSettings = Join-Path -Path $Tests -ChildPath "PSScriptAnalyzerSettings.psd1"
    # Out
    Out                         = $Out
    OutModule                   = Join-Path -Path $Out -ChildPath "$ModuleName.psm1"
    OutManifest                 = Join-Path -Path $Out -ChildPath "$ModuleName.psd1"
    OutEncoding                 = "utf8"  # Type [string]
    # Docs
    Docs                        = $Docs
    DocsHelpOut                 = Join-Path -Path $Docs -ChildPath "cmdlet-help"
    DocsHelpOutEncoding         = "UTF-8"  # Type [System.Text.Encoding]
    DocsHelpLocale              = "EN-US"
    # Publish
    PublishApiKeyEnvVar         = "{0}_API_KEY" -f $ModuleName
    PublishRepository           = "PSGallery"
}

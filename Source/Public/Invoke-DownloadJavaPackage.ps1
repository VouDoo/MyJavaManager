function Invoke-DownloadJavaPackage {

    <#

    .SYNOPSIS
    Download a Java package.

    .DESCRIPTION
    Download and install a Java package from Adoptium and add an associated entry to the inventory file.

    .PARAMETER Version
    Version of Java to download.

    .INPUTS
    None. You cannot pipe objects to Invoke-DownloadJavaPackage.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Invoke-DownloadJavaPackage

    If in interactive PowerShell session, select a version of Java using menu.
    Else, pick the latest available version of Java.
    Download and install the Java package in the .java_package folder.

    .EXAMPLE
    PS> Invoke-DownloadJavaPackage -Version 11

    Download and install Java 11 in the .java_package folder.

    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope = "Function", Target = "*")]
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Position = 0,
            HelpMessage = "Version of Java to download"
        )]
        [int] $Version
    )

    begin {
        $InformationPreference = "Continue"
        $ErrorActionPreference = "Stop"
        $AvailableVersions = [AdoptiumApi]::GetAvailableFeatureVersions()
        $DestinationDirectory = Join-Path -Path $HOME -ChildPath ".java_packages"
    }

    process {
        if ($Version) {
            if ($Version -notin $AvailableVersions) {
                Write-Error -Message ("Java version $Version is not available. Available versions: {0}." -f ($AvailableVersions -join ", "))
            }
        }
        else {
            if ([Environment]::UserInteractive) {
                $Version = Use-InteractiveSelectionMenu -Items $AvailableVersions -Header "Select Java version:"
                if (-not $Version) { break }
            }
            else {
                $Version = ($AvailableVersions | Measure-Object -Maximum).Maximum
            }
        }

        $Package = New-Object -TypeName AdoptiumPackage -ArgumentList $Version

        if ($PSCmdlet.ShouldProcess($DestinationDirectory, ("Download and install Java package '{0}' to directory" -f $Package.Name))) {
            if (-not (Test-Path -Path $DestinationDirectory -PathType Container)) {
                New-Item -Path $DestinationDirectory -ItemType Directory | Out-Null
            }

            Write-Information -MessageData ("Downloading Java package `"{0}`"..." -f $Package.Name)
            $PackageObject = $Package.Download($DestinationDirectory)
            $PackagePath = $PackageObject.FullName
            Write-Information -MessageData "Java package installed in `"$PackagePath`"."

            try {
                Add-JavaEntry -Path $PackagePath
            }
            catch {
                Write-Error -Message ("Cannot add Java entry to the inventory file: {0}" -f $_.Exception.Message)
            }
        }
    }
}

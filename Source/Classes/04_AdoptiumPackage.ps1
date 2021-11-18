class AdoptiumPackage {
    [string] $Name
    [string] $Uri
    [string] $Checksum

    AdoptiumPackage([int] $FeatureVersion) {
        $Asset = [AdoptiumApi]::GetLatestAsset($FeatureVersion)

        $this.Name = $Asset.release_name
        $this.Uri = $Asset.binary.package.link
        $this.Checksum = $Asset.binary.package.checksum
    }

    [System.IO.FileSystemInfo] Download($DestinationDirectory) {

        <#
        .Description
        Download and expand a Java package from Adoptium to a destination directory.
        #>

        $TempGuid = New-Guid
        $TempDirectory = Join-Path -Path $env:TEMP -ChildPath "java_$TempGuid"

        $DownloadDestinationArchive = Join-Path -Path $TempDirectory -ChildPath "package.zip"

        try {
            # Create temporary directory
            New-Item -Path $TempDirectory -ItemType Directory | Out-Null
            Write-Debug -Message "Temporary directory created `"$TempDirectory`"."

            # Download archive
            $WebClient = New-Object -TypeName System.Net.WebClient
            $WebClient.DownloadFile($this.Uri, $DownloadDestinationArchive)
            Write-Debug -Message ("Java archive `"$DownloadDestinationArchive`" downloaded from `"{0}`"." -f $this.Uri)

            # Validate checksum
            if ((Get-FileHash -Path $DownloadDestinationArchive).Hash -eq $this.Checksum) {
                Write-Debug -Message "Downloaded file `"$DownloadDestinationArchive`" checksum matches to the public one."
            }
            else {
                throw "Downloaded file `"$DownloadDestinationArchive`" checksum does not match to the public one."
            }

            # Expand archive
            Expand-Archive -Path $DownloadDestinationArchive -DestinationPath $TempDirectory
            Write-Debug -Message "Java archive `"$DownloadDestinationArchive`" extracted to `"$TempDirectory`"."

            # Move to destination directory
            $SourcePath = Join-Path -Path $TempDirectory -ChildPath $this.Name
            $DestinationPath = Join-Path -Path $DestinationDirectory -ChildPath $this.Name
            if (Test-Path -Path $DestinationPath) {
                throw "Package `"{0}`" already exists in destination directory `"{1}`"." -f $this.Name, $DestinationDirectory
            }
            $Item = Move-Item -Path $SourcePath -Destination $DestinationPath -Force -PassThru
            Write-Debug -Message "Java package `"$SourcePath`" moved to `"$DestinationPath`"."
        }
        catch {
            throw "Cannot download Java package: {0}" -f $_.Exception.Message
        }
        finally {
            Remove-Item -Path $TempDirectory -Recurse -Force
        }

        return $Item
    }
}

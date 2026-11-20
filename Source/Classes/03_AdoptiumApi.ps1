class AdoptiumApi {

    # API documentation: https://api.adoptium.net/q/swagger-ui/

    static [int[]] GetAvailableFeatureVersions() {

        <#
        .Description
        Get the available feature versions of Java.
        #>

        $RestMethodParams = @{
            Method = "Get"
            Uri    = "https://api.adoptium.net/v3/info/available_releases"
        }
        $RestMethodResult = Invoke-RestMethod @RestMethodParams

        return $RestMethodResult.available_releases
    }

    static [int[]] GetAvailableLtsVersions() {

        <#
        .Description
        Get the available LTS (Long-Term Support) feature versions of Java.
        #>

        $RestMethodParams = @{
            Method = "Get"
            Uri    = "https://api.adoptium.net/v3/info/available_releases"
        }
        $RestMethodResult = Invoke-RestMethod @RestMethodParams

        return $RestMethodResult.available_lts_releases
    }

    static [string] GetArchitecture() {

        <#
        .Description
        Get the architecture of the system, as named by the Adoptium API.
        #>

        # Read from the Machine scope to get the architecture of the system,
        # even when PowerShell runs as an x64 process on an ARM64 system (emulation).
        $ProcessorArchitecture = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE", [System.EnvironmentVariableTarget]::Machine)
        if ($ProcessorArchitecture -eq "ARM64") {
            return "aarch64"
        }
        return "x64"
    }

    static [object] GetLatestAsset([int] $FeatureVersion, [string] $Architecture) {

        <#
        .Description
        Get the latest assets of a Java feature version for an architecture.
        #>

        $RestMethodParams = @{
            Method = "Get"
            Uri    = "https://api.adoptium.net/v3/assets/latest/$FeatureVersion/hotspot"
        }
        $RestMethodResult = Invoke-RestMethod @RestMethodParams

        return $RestMethodResult | Where-Object -FilterScript {
            $_.binary.architecture -eq $Architecture -and
            $_.binary.heap_size -eq "normal" -and
            $_.binary.image_type -eq "jdk" -and
            $_.binary.jvm_impl -eq "hotspot" -and
            $_.binary.os -eq "windows" -and
            $_.binary.project -eq "jdk"
        } | Select-Object -First 1
    }
}

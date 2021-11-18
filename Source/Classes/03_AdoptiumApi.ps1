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

    static [object] GetLatestAsset([int] $FeatureVersion) {

        <#
        .Description
        Get the latest assets of a Java feature version.
        #>

        $RestMethodParams = @{
            Method = "Get"
            Uri    = "https://api.adoptium.net/v3/assets/latest/$FeatureVersion/hotspot"
        }
        $RestMethodResult = Invoke-RestMethod @RestMethodParams

        return $RestMethodResult | Where-Object -FilterScript {
            $_.binary.architecture -eq "x64" -and
            $_.binary.heap_size -eq "normal" -and
            $_.binary.image_type -eq "jdk" -and
            $_.binary.jvm_impl -eq "hotspot" -and
            $_.binary.os -eq "windows" -and
            $_.binary.project -eq "jdk"
        } | Select-Object -First 1
    }
}

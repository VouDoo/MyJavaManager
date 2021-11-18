class PathFormat {
    static [string] NormalizePath([string] $Path) {

        <#
        .Description
        Format a given string to a normalized path.
        #>

        $Path_ = $Path
        $Path_ = [System.IO.Path]::GetFullPath($Path_)
        $Path_ = $Path_.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        return $Path_
    }
}

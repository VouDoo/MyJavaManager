function Test-JavaHomeDirectory {

    <#

    .SYNOPSIS
    Test Java home directory.

    .DESCRIPTION
    Test if a given directory is a Java home directory.

    .PARAMETER Path
    Path to the directory.

    .INPUTS
    None. You cannot pipe objects to Test-JavaHomeDirectory.

    .OUTPUTS
    System.Boolean. True if directory is a Java home directory.

    .EXAMPLE
    PS> Test-JavaHomeDirectory -Path C:\path\to\java_home_directory
    $true

    Test Java home directory.

    #>

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Path to the directory"
        )]
        [string] $Path
    )

    process {
        $JavaApplicatonPath = Join-Path -Path $Path -ChildPath "bin\java.exe"

        $IsDirectory = Test-Path -Path $Path -PathType Container
        Write-Debug -Message "Is `"$Path`" a directory? $IsDirectory."

        $JavaApplicatonExists = Test-Path -Path $JavaApplicatonPath -PathType Leaf
        Write-Debug -Message "Does `"$JavaApplicatonPath`" exist? $JavaApplicatonExists."

        $IsDirectory -and $JavaApplicatonExists
    }
}

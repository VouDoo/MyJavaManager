function Get-JavaVersion {

    <#

    .SYNOPSIS
    Get Java version.

    .DESCRIPTION
    Get version of a Java application.

    .PARAMETER Path
    Path to the Java home directory.

    .INPUTS
    None. You cannot pipe objects to Get-JavaVersion.

    .OUTPUTS
    System.String. Version of the Java application.

    .EXAMPLE
    PS> Get-JavaVersion -Path C:\path\to\java_home_directory
    jdk-11.0.13.0

    Get version of the Java application.

    #>

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Path to the Java home directory"
        )]
        [string] $Path
    )

    process {
        $JavaApplicatonPath = Join-Path -Path $Path -ChildPath "bin\java.exe"
        $JavaCompilerPath = Join-Path -Path $Path -ChildPath "bin\javac.exe"

        try {
            $Version = (Get-Command -Name $JavaApplicatonPath -ErrorAction Stop).Version.ToString()
            Write-Debug -Message "Version of Java application `"$JavaApplicatonPath`" is `"$Version`"."
        }
        catch {
            throw "Cannot get the version of Java application."
        }

        if (Get-Command -Name $JavaCompilerPath -ErrorAction SilentlyContinue) {
            $Type = "jdk"
            Write-Debug -Message "Java compiler `"$JavaCompilerPath`" exists. Assuming it is JDK (Java Development Kit)."
        }
        else {
            $Type = "jre"
            Write-Debug -Message "Java compiler `"$JavaCompilerPath`" does not exist. Assuming it is JRE (Java Runtime Environment)."
        }

        "{0}-{1}" -f $Type, $Version
    }
}

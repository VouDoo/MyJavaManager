function Use-InteractiveSelectionMenu {

    <#

    .SYNOPSIS
    Use interactive selection menu.

    .DESCRIPTION
    Use interactive selection menu with given items inside the PowerShell console.

    .PARAMETER Items
    List of items to add in the menu.

    .INPUTS
    None. You cannot pipe objects to Use-InteractiveSelectionMenu.

    .OUTPUTS
    System.String. The selected item.

    .EXAMPLE
    PS> Use-InteractiveSelectionMenu -Items @("item1", "item2", "item3")
    > item1
      item2
      item3

    Show interactive menu to select an item.

    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Scope = "Function", Target = "*")]
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "List of items to add in the menu"
        )]
        [array] $Items
    )

    process {
        $FirstPrint = $true
        $Position = 0
        $Entered = $false
        $Escaped = $false

        if ($Items.Length -gt 0) {
            try {
                [System.Console]::CursorVisible = $false

                while (-not $Entered -and -not $Escaped) {
                    if (-not $FirstPrint) {
                        $Host.UI.RawUI.FlushInputBuffer()
                        $Key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

                        switch ($Key.VirtualKeyCode) {
                            <# Key mapping
                            38 = UP ARROW
                            75 = K
                            #>
                            { $_ -in 38, 75 -and $Position -gt 0 } { $Position-- }

                            <# Key mapping
                            40 = DOWN ARROW
                            74 = J
                            #>
                            { $_ -in 40, 74 -and $Position -lt $Items.Length - 1 } { $Position++ }

                            <# Key mapping
                            33 = PAGE UP
                            36 = HOME
                            #>
                            { $_ -in 33, 36 } { $Position = 0 }

                            <# Key mapping
                            34 = PAGE DOWN
                            35 = END
                            #>
                            { $_ -in 34, 35 } { $Position = $Items.Length - 1 }

                            <# Key mapping
                            13 = ENTER
                            #>
                            13 { $Entered = $true }

                            <# Key mapping
                            27 = ESC
                            #>
                            27 { $Escaped = $true }
                        }

                        $StartPosition = [System.Console]::CursorTop - $Items.Length
                        [System.Console]::SetCursorPosition(0, $StartPosition)
                    }
                    else { $FirstPrint = $false }

                    # Print to console
                    for ($i = 0; $i -lt $Items.Length; $i++) {
                        if ($i -eq $Position) {
                            Write-Host ">" $Items[$i] -ForegroundColor Yellow
                        }
                        else {
                            Write-Host " " $Items[$i]
                        }
                    }
                }
            }
            finally {
                [System.Console]::SetCursorPosition(0, $StartPosition + $Items.Length)
                [System.Console]::CursorVisible = $true
            }
        }

        if ($Entered) {
            $Items[$Position]
        }
        else {
            $null
        }
    }
}

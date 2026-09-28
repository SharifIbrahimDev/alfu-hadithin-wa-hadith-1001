# ==============================================================================
# 1001 Authentic Hadith - Release APK Builder Script
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host " 1001 AUTHENTIC HADITH - ANDROID APK BUILDER" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

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
    Write-Host "  Package ID:      com.sharifibrahimdev.alfuhadithin" -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] APK file not found at: $ApkPath" -ForegroundColor Red
    exit 1
}

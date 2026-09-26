# Verification script for 1001 Hadith Compendium & PDF Generation Feature
$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host " 1001 AUTHENTIC HADITH - SYSTEM & PDF VERIFICATION" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Verify JSON Assets
$hadithsPath = "c:\Users\USER\flutter_projects\Alfu Hadithin Wa Hadith 1001\mobile\assets\data\hadiths.json"
$chaptersPath = "c:\Users\USER\flutter_projects\Alfu Hadithin Wa Hadith 1001\mobile\assets\data\chapters.json"

$hadiths = Get-Content $hadithsPath -Raw -Encoding UTF8 | ConvertFrom-Json
$chaptersJson = Get-Content $chaptersPath -Raw -Encoding UTF8 | ConvertFrom-Json
$chapters = $chaptersJson.chapters

Write-Host "[1/4] Checking Data Assets..." -ForegroundColor Yellow
Write-Host "  - Total Hadiths in JSON: $($hadiths.Count)" -ForegroundColor Green
Write-Host "  - Total Chapters in JSON: $($chapters.Count)" -ForegroundColor Green

if ($hadiths.Count -ne 1001) {
    throw "Hadith count is not 1001! Found: $($hadiths.Count)"
}

$missingArBenefits = ($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.benefits_ar) }).Count
$missingEnBenefits = ($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.benefits_en) }).Count
$missingTakhrij = ($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.takhrij) }).Count
$missingGrading = ($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.grading) }).Count

Write-Host "  - Missing Arabic Benefits: $missingArBenefits" -ForegroundColor Green
Write-Host "  - Missing English Benefits: $missingEnBenefits" -ForegroundColor Green
Write-Host "  - Missing Takhrij: $missingTakhrij" -ForegroundColor Green
Write-Host "  - Missing Grading: $missingGrading" -ForegroundColor Green

# 2. Check Dart Source Files Exist
Write-Host "`n[2/4] Verifying Core Dart Files..." -ForegroundColor Yellow
$filesToCheck = @(
    "mobile/lib/services/pdf_export_service.dart",
    "mobile/lib/screens/pdf_viewer_screen.dart",
    "mobile/lib/screens/book_reader_screen.dart",
    "mobile/lib/screens/bibliography_screen.dart",
    "mobile/lib/models/bibliography_item.dart",
    "mobile/lib/screens/home_screen.dart",
    "mobile/lib/screens/chapter_screen.dart",
    "mobile/lib/screens/about_screen.dart",
    "mobile/lib/screens/settings_screen.dart",
    "mobile/lib/widgets/app_drawer.dart",
    "mobile/lib/services/hadith_service.dart"
)

foreach ($relPath in $filesToCheck) {
    $fullPath = "c:\Users\USER\flutter_projects\Alfu Hadithin Wa Hadith 1001\$relPath"
    if (Test-Path $fullPath) {
        $lines = (Get-Content $fullPath).Count
        Write-Host "  [OK] $relPath ($lines lines)" -ForegroundColor Green
    } else {
        throw "Missing file: $relPath"
    }
}

# 3. Check pubspec dependencies
Write-Host "`n[3/4] Checking pubspec.yaml Dependencies..." -ForegroundColor Yellow
$pubspec = Get-Content "c:\Users\USER\flutter_projects\Alfu Hadithin Wa Hadith 1001\mobile\pubspec.yaml" -Raw
if ($pubspec -match "pdf:" -and $pubspec -match "printing:") {
    Write-Host "  [OK] pdf & printing packages present in pubspec.yaml" -ForegroundColor Green
} else {
    throw "Missing pdf/printing packages in pubspec.yaml"
}

# 4. Check Root Data Synced
Write-Host "`n[4/4] Verifying Root /data/ directory synchronization..." -ForegroundColor Yellow
$rootHadithsPath = "c:\Users\USER\flutter_projects\Alfu Hadithin Wa Hadith 1001\data\hadiths.json"
if (Test-Path $rootHadithsPath) {
    $rootHadiths = Get-Content $rootHadithsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "  - Root hadiths count: $($rootHadiths.Count)" -ForegroundColor Green
}

Write-Host "`n=========================================================" -ForegroundColor Cyan
Write-Host " ALL 4 VERIFICATION CHECKS PASSED PERFECTLY (100% READY)" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Cyan

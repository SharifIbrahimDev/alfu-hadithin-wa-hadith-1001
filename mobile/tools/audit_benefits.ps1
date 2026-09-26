$content = Get-Content -Raw -Encoding UTF8 'assets/data/hadiths.json'
$items = $content | ConvertFrom-Json

$hasBoth = 0
$hasOnlyAr = 0
$hasOnlyEn = 0
$hasNeither = 0

$missingAr = @()
$missingEn = @()

foreach ($item in $items) {
    $id = $item.id
    $bAr = if ($null -ne $item.benefits_ar) { $item.benefits_ar.Trim() } else { "" }
    $bEn = if ($null -ne $item.benefits_en) { $item.benefits_en.Trim() } else { "" }

    $isArEmpty = [string]::IsNullOrWhiteSpace($bAr)
    $isEnEmpty = [string]::IsNullOrWhiteSpace($bEn)

    if (-not $isArEmpty -and -not $isEnEmpty) {
        $hasBoth++
    } elseif (-not $isArEmpty -and $isEnEmpty) {
        $hasOnlyAr++
    } elseif ($isArEmpty -and -not $isEnEmpty) {
        $hasOnlyEn++
    } else {
        $hasNeither++
    }

    if ($isArEmpty) { $missingAr += $id }
    if ($isEnEmpty) { $missingEn += $id }
}

Write-Host "=========================================="
Write-Host "FAWAIDUL HADITH (BENEFITS) BREAKDOWN"
Write-Host "=========================================="
Write-Host "Total Hadiths in DB: $($items.Count)"
Write-Host "Has BOTH Arabic & English benefits: $hasBoth"
Write-Host "Has ONLY Arabic benefits: $hasOnlyAr"
Write-Host "Has ONLY English benefits: $hasOnlyEn"
Write-Host "Has NEITHER (Completely missing): $hasNeither"
Write-Host "------------------------------------------"
Write-Host "Total missing Arabic benefits: $($missingAr.Count)"
Write-Host "Total missing English benefits: $($missingEn.Count)"
Write-Host "=========================================="

Write-Host "`nSample of Hadith #1:"
$h1 = $items | Where-Object { $_.id -eq 1 }
Write-Host "Ar: $($h1.benefits_ar)"
Write-Host "En: $($h1.benefits_en)"

Write-Host "`nSample of Hadith #2:"
$h2 = $items | Where-Object { $_.id -eq 2 }
Write-Host "Ar: $($h2.benefits_ar)"
Write-Host "En: $($h2.benefits_en)"

Write-Host "`nSample of Hadith #352:"
$h352 = $items | Where-Object { $_.id -eq 352 }
Write-Host "Topic: $($h352.topic_en)"
Write-Host "Ar Matn: $($h352.arabic_matn)"
Write-Host "En Translation: $($h352.english_translation)"
Write-Host "Ar benefits: $($h352.benefits_ar)"
Write-Host "En benefits: $($h352.benefits_en)"

Write-Host "`nSample of Hadith #500:"
$h500 = $items | Where-Object { $_.id -eq 500 }
Write-Host "Topic: $($h500.topic_en)"
Write-Host "Ar Matn: $($h500.arabic_matn)"
Write-Host "En Translation: $($h500.english_translation)"
Write-Host "Ar benefits: $($h500.benefits_ar)"
Write-Host "En benefits: $($h500.benefits_en)"

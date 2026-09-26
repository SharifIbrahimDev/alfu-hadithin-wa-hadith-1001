$json = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/hadiths.json' | ConvertFrom-Json
Write-Host "Total Hadiths loaded: $($json.Count)"

function Get-ChapterStats {
    param($min, $max)
    $slice = $json | Where-Object { $_.id -ge $min -and $_.id -le $max }
    $noAr = ($slice | Where-Object { [string]::IsNullOrWhiteSpace($_.benefits_ar) }).Count
    $noEn = ($slice | Where-Object { [string]::IsNullOrWhiteSpace($_.benefits_en) }).Count
    Write-Host "Range $min..$max -> Count: $($slice.Count), Missing Ar: $noAr, Missing En: $noEn"
}

Get-ChapterStats 1 50
Get-ChapterStats 51 100
Get-ChapterStats 101 150
Get-ChapterStats 151 200
Get-ChapterStats 201 250
Get-ChapterStats 251 300
Get-ChapterStats 301 351
Get-ChapterStats 352 400
Get-ChapterStats 401 500
Get-ChapterStats 501 600
Get-ChapterStats 601 700
Get-ChapterStats 701 800
Get-ChapterStats 801 900
Get-ChapterStats 901 1001

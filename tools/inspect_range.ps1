param([int]$start, [int]$end)
$json = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/hadiths.json' | ConvertFrom-Json
$slice = $json | Where-Object { $_.id -ge $start -and $_.id -le $end }
foreach ($item in $slice) {
    [PSCustomObject]@{
        id = $item.id
        topic_en = $item.topic_en
        arabic_matn = if ($item.arabic_matn.Length -gt 60) { $item.arabic_matn.Substring(0, 60) + "..." } else { $item.arabic_matn }
        benefits_ar = $item.benefits_ar
        benefits_en = $item.benefits_en
    } | Format-List
}

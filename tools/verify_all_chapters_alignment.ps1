$json = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/hadiths.json' | ConvertFrom-Json
$chObj = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/chapters.json' | ConvertFrom-Json
$chapters = $chObj.chapters

Write-Host "=========================================================="
Write-Host "CHAPTER THEMATIC ALIGNMENT AUDIT (ALL 21 CHAPTERS)"
Write-Host "=========================================================="

foreach ($ch in $chapters) {
    if ($ch.id -eq 21) { continue }
    $slice = @($json | Where-Object { $_.chapter_id -eq $ch.id })
    if ($slice.Count -eq 0) {
        Write-Host "Warning: No hadiths found for Chapter $($ch.id)"
        continue
    }
    Write-Host "`n--- Chapter $($ch.id): $($ch.english_title) [IDs $($ch.start_id)..$($ch.end_id)] (Count: $($slice.Count)) ---"
    
    $first = $slice[0]
    $mid = $slice[[int]($slice.Count / 2)]
    $last = $slice[-1]
    
    Write-Host "  First (ID $($first.id)): TopicEn='$($first.topic_en)'"
    Write-Host "    Ar: $(if ($null -ne $first.benefits_ar -and $first.benefits_ar.Length -gt 60) { $first.benefits_ar.Substring(0, 60) + '...' } else { $first.benefits_ar })"
    Write-Host "    En: $(if ($null -ne $first.benefits_en -and $first.benefits_en.Length -gt 60) { $first.benefits_en.Substring(0, 60) + '...' } else { $first.benefits_en })"

    Write-Host "  Mid (ID $($mid.id)): TopicEn='$($mid.topic_en)'"
    Write-Host "    Ar: $(if ($null -ne $mid.benefits_ar -and $mid.benefits_ar.Length -gt 60) { $mid.benefits_ar.Substring(0, 60) + '...' } else { $mid.benefits_ar })"
    Write-Host "    En: $(if ($null -ne $mid.benefits_en -and $mid.benefits_en.Length -gt 60) { $mid.benefits_en.Substring(0, 60) + '...' } else { $mid.benefits_en })"

    Write-Host "  Last (ID $($last.id)): TopicEn='$($last.topic_en)'"
    Write-Host "    Ar: $(if ($null -ne $last.benefits_ar -and $last.benefits_ar.Length -gt 60) { $last.benefits_ar.Substring(0, 60) + '...' } else { $last.benefits_ar })"
    Write-Host "    En: $(if ($null -ne $last.benefits_en -and $last.benefits_en.Length -gt 60) { $last.benefits_en.Substring(0, 60) + '...' } else { $last.benefits_en })"
}

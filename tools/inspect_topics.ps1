$json = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/hadiths.json' | ConvertFrom-Json
$chapters = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/chapters.json' | ConvertFrom-Json

Write-Host "=== CHAPTERS LIST ==="
foreach ($ch in $chapters) {
    Write-Host "Ch $($ch.id): $($ch.title_en) | Range: $($ch.start_id)..$($ch.end_id) | Count: $($ch.hadith_count)"
}

Write-Host "`n=== SAMPLE HADITHS TOPICS & AR BENEFITS ==="
function Show-HadithInfo($start, $end) {
    $slice = $json | Where-Object { $_.id -ge $start -and $_.id -le $end }
    foreach ($h in $slice) {
        Write-Host "ID $($h.id) [Ch $($h.chapter_id)]: $($h.topic_en)"
        Write-Host "   Ar Ben: $($h.benefits_ar)"
        Write-Host "   En Ben: $($h.benefits_en)"
    }
}

Show-HadithInfo 198 205
Show-HadithInfo 248 255
Show-HadithInfo 298 305
Show-HadithInfo 348 355

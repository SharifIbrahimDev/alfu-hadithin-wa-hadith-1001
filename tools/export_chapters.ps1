$json = Get-Content -Raw -Encoding UTF8 'mobile/assets/data/hadiths.json' | ConvertFrom-Json

function Export-ChapterForTranslation($chId, $outFile) {
    $slice = $json | Where-Object { $_.chapter_id -eq $chId }
    $list = @()
    foreach ($h in $slice) {
        $list += [PSCustomObject]@{
            id = $h.id
            chapter_id = $h.chapter_id
            topic_ar = $h.topic_ar
            topic_en = $h.topic_en
            arabic_matn = if ($h.arabic_matn.Length -gt 80) { $h.arabic_matn.Substring(0, 80) + "..." } else { $h.arabic_matn }
            benefits_ar = $h.benefits_ar
            benefits_en = $h.benefits_en
        }
    }
    $list | ConvertTo-Json -Depth 5 | Set-Content -Path $outFile -Encoding UTF8
    Write-Host "Exported $($list.Count) hadiths for Chapter $chId to $outFile"
}

Export-ChapterForTranslation 3 'tools/fawaid/ch3_prayer.json'
Export-ChapterForTranslation 4 'tools/fawaid/ch4_zakah.json'
Export-ChapterForTranslation 5 'tools/fawaid/ch5_fasting.json'
Export-ChapterForTranslation 6 'tools/fawaid/ch6_hajj.json'
Export-ChapterForTranslation 7 'tools/fawaid/ch7_knowledge.json'

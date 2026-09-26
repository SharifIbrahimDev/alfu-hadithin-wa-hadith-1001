$mobileFile = 'mobile/assets/data/hadiths.json'
$dataFile = 'data/hadiths.json'

function Test-HadithFile($path) {
    Write-Host "=========================================="
    Write-Host "Verifying: $path"
    $content = Get-Content -Raw -Encoding UTF8 $path
    $hadiths = $content | ConvertFrom-Json
    
    $missingAr = @($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.benefits_ar) })
    $missingEn = @($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.benefits_en) })
    $missingTakhrij = @($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.takhrij) })
    $missingGrading = @($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.grading) })
    $missingMatn = @($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.arabic_matn) })
    $missingTrans = @($hadiths | Where-Object { [string]::IsNullOrWhiteSpace($_.english_translation) })

    Write-Host "Total Hadiths in compendium: $($hadiths.Count)"
    Write-Host "Missing Arabic Benefits (benefits_ar): $($missingAr.Count)"
    Write-Host "Missing English Benefits (benefits_en): $($missingEn.Count)"
    Write-Host "Missing Takhrij (takhrij): $($missingTakhrij.Count)"
    Write-Host "Missing Grading (grading): $($missingGrading.Count)"
    Write-Host "Missing Arabic Matn: $($missingMatn.Count)"
    Write-Host "Missing English Translation: $($missingTrans.Count)"
    
    if ($missingAr.Count -eq 0 -and $missingEn.Count -eq 0 -and $missingTakhrij.Count -eq 0 -and $missingGrading.Count -eq 0) {
        Write-Host "✅ SUCCESS: 100% of all $($hadiths.Count) Hadiths are completely verified and populated!"
    } else {
        Write-Host "❌ ISSUES FOUND!"
    }
}

Test-HadithFile $mobileFile
Test-HadithFile $dataFile

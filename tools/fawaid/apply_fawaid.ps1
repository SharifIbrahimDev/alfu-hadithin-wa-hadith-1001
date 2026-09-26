# Script to apply all generated fawaid into hadiths.json (both mobile and data dirs)
param(
    [string]$BatchFile
)

$mobilePath = 'mobile/assets/data/hadiths.json'
$dataPath = 'data/hadiths.json'

if (-not (Test-Path $mobilePath)) {
    Write-Error "mobile/assets/data/hadiths.json not found!"
    exit 1
}

$hadiths = Get-Content -Raw -Encoding UTF8 $mobilePath | ConvertFrom-Json

Write-Host "Applying batch: $BatchFile"
$batchData = Get-Content -Raw -Encoding UTF8 $BatchFile | ConvertFrom-Json

$updated = 0
foreach ($entry in $batchData) {
    $id = $entry.id
    $match = $hadiths | Where-Object { $_.id -eq $id }
    if ($match) {
        if ($null -ne $entry.benefits_ar -and -not [string]::IsNullOrWhiteSpace($entry.benefits_ar)) {
            $match.benefits_ar = $entry.benefits_ar.Trim()
        }
        if ($null -ne $entry.benefits_en -and -not [string]::IsNullOrWhiteSpace($entry.benefits_en)) {
            $match.benefits_en = $entry.benefits_en.Trim()
        }
        $updated++
    }
}

$jsonOutput = $hadiths | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText((Resolve-Path $mobilePath), $jsonOutput, [System.Text.Encoding]::UTF8)
if (Test-Path $dataPath) {
    [System.IO.File]::WriteAllText((Resolve-Path $dataPath), $jsonOutput, [System.Text.Encoding]::UTF8)
}

Write-Host "Successfully updated $updated hadiths in both mobile and root data directories!"

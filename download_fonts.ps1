$baseURL = "https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/SimplifiedChinese/"
$fonts = @("NotoSansSC-Regular.otf", "NotoSansSC-Medium.otf", "NotoSansSC-Bold.otf")
$destDir = "C:\Users\Administrator\.openclaw\workspace\fund_master_app\assets\fonts"

if (-not (Test-Path $destDir)) { 
    Write-Host "Creating font directory: $destDir"
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

Write-Host "Starting font download..."
foreach ($font in $fonts) {
    $url = $baseURL + $font
    $outFile = Join-Path $destDir $font
    try {
        Write-Host "Downloading $font from $url..."
        Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing -TimeoutSec 30
        if (Test-Path $outFile) {
            $size = (Get-Item $outFile).Length
            Write-Host "✓ Success: $font ($size bytes)"
        } else {
            Write-Error "Download succeeded but file not found: $outFile"
        }
    } catch {
        Write-Error "Failed to download $font: $($_.Exception.Message)"
    }
}
Write-Host "Font download completed."
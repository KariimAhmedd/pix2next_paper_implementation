# Quick CUDA Download Progress Checker
$file = "$env:TEMP\cuda_11.7.0_windows.exe"

if (Test-Path $file) {
    $f = Get-Item $file
    $mb = [math]::Round($f.Length / 1MB, 2)
    $gb = [math]::Round($f.Length / 1GB, 3)
    $pct = [math]::Round(($f.Length / (3.0 * 1GB)) * 100, 1)
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "CUDA Toolkit 11.7.0 Download Progress" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Size: $mb MB ($gb GB)" -ForegroundColor Yellow
    Write-Host "Progress: $pct%" -ForegroundColor Green
    Write-Host "Expected: ~3 GB" -ForegroundColor White
    Write-Host "Last Updated: $($f.LastWriteTime)" -ForegroundColor Gray
    Write-Host ""
    
    if ($pct -lt 100) {
        Write-Host "Download in progress..." -ForegroundColor Yellow
    } else {
        Write-Host "Download complete!" -ForegroundColor Green
    }
} else {
    Write-Host "Download file not found." -ForegroundColor Red
}


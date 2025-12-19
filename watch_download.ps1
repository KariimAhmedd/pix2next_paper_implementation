# Real-time Download Progress Monitor
$file = "$env:TEMP\cuda_11.7.0_windows.exe"
$expectedSize = 3.0 * 1GB

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CUDA Toolkit Download Monitor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Gray
Write-Host ""

$previousSize = 0
$stallCount = 0

while ($true) {
    if (Test-Path $file) {
        $f = Get-Item $file
        $currentSize = $f.Length
        $mb = [math]::Round($currentSize / 1MB, 2)
        $gb = [math]::Round($currentSize / 1GB, 3)
        $pct = [math]::Round(($currentSize / $expectedSize) * 100, 1)
        
        Clear-Host
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "CUDA Toolkit Download Progress" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Size: $mb MB ($gb GB)" -ForegroundColor Yellow
        Write-Host "Progress: $pct%" -ForegroundColor Green
        Write-Host "Expected: ~3 GB" -ForegroundColor White
        Write-Host "Last Updated: $($f.LastWriteTime)" -ForegroundColor Gray
        Write-Host ""
        
        if ($currentSize -gt $previousSize) {
            $speed = ($currentSize - $previousSize) / 2  # bytes per second (2 second interval)
            $speedMBps = [math]::Round($speed / 1MB, 2)
            $remaining = ($expectedSize - $currentSize) / $speed if $speed -gt 0 else 0
            $remainingMin = [math]::Round($remaining / 60, 1)
            
            Write-Host "Speed: $speedMBps MB/s" -ForegroundColor Green
            if ($remainingMin -gt 0 -and $remainingMin -lt 1000) {
                Write-Host "Estimated time remaining: $remainingMin minutes" -ForegroundColor Cyan
            }
            $stallCount = 0
        } else {
            $stallCount++
            if ($stallCount -gt 3) {
                Write-Host "Download appears stalled. Checking BITS..." -ForegroundColor Yellow
                $bitsJob = Get-BitsTransfer | Where-Object { $_.DisplayName -like "*CUDA*" } | Select-Object -First 1
                if ($bitsJob) {
                    Write-Host "BITS Job State: $($bitsJob.JobState)" -ForegroundColor Yellow
                }
            }
        }
        
        if ($pct -ge 99) {
            Write-Host ""
            Write-Host "Download appears complete!" -ForegroundColor Green
            break
        }
        
        $previousSize = $currentSize
    } else {
        Write-Host "Waiting for download to start..." -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Monitoring stopped." -ForegroundColor Gray


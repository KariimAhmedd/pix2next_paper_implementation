# Monitor BITS Transfer Progress
$job = Get-BitsTransfer | Where-Object { $_.DisplayName -like "*CUDA*" } | Select-Object -First 1

if ($job) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "CUDA Toolkit Download Status" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Job State: $($job.JobState)" -ForegroundColor Yellow
    Write-Host ""
    
    if ($job.BytesTotal -gt 0) {
        $bytesTransferred = $job.BytesTransferred
        $bytesTotal = $job.BytesTotal
        $percent = [math]::Round(($bytesTransferred / $bytesTotal) * 100, 2)
        $mbTransferred = [math]::Round($bytesTransferred / 1MB, 2)
        $mbTotal = [math]::Round($bytesTotal / 1MB, 2)
        $gbTransferred = [math]::Round($bytesTransferred / 1GB, 2)
        $gbTotal = [math]::Round($bytesTotal / 1GB, 2)
        
        Write-Host "Transferred: $mbTransferred MB ($gbTransferred GB)" -ForegroundColor Green
        Write-Host "Total: $mbTotal MB ($gbTotal GB)" -ForegroundColor White
        Write-Host "Progress: $percent%" -ForegroundColor Yellow
        Write-Host ""
        
        if ($job.JobState -eq "Transferring") {
            Write-Host "Status: Downloading..." -ForegroundColor Green
        } elseif ($job.JobState -eq "Transferred") {
            Write-Host "Status: Download complete! Completing transfer..." -ForegroundColor Green
            Complete-BitsTransfer -BitsJob $job
        } elseif ($job.JobState -eq "Error") {
            Write-Host "Status: Error - $($job.ErrorDescription)" -ForegroundColor Red
        }
    } else {
        Write-Host "Bytes transferred: $([math]::Round($job.BytesTransferred / 1MB, 2)) MB" -ForegroundColor Yellow
        Write-Host "Total size: Unknown (still connecting...)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "To check again, run this script again." -ForegroundColor Gray
    Write-Host "To cancel: Remove-BitsTransfer -BitsJob `$job" -ForegroundColor Gray
} else {
    Write-Host "No active BITS transfer found." -ForegroundColor Yellow
    Write-Host "Checking file status..." -ForegroundColor Gray
    
    $file = "$env:TEMP\cuda_11.7.0_windows.exe"
    if (Test-Path $file) {
        $f = Get-Item $file
        $mb = [math]::Round($f.Length / 1MB, 2)
        $gb = [math]::Round($f.Length / 1GB, 2)
        $pct = [math]::Round(($f.Length / (3.0 * 1GB)) * 100, 1)
        
        Write-Host "File exists: $mb MB ($gb GB) - $pct%" -ForegroundColor Green
        Write-Host "Last modified: $($f.LastWriteTime)" -ForegroundColor Gray
    } else {
        Write-Host "Download file not found." -ForegroundColor Red
    }
}


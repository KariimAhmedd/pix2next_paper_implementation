# Resume CUDA Toolkit Download
$url = "https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_516.01_windows.exe"
$output = "$env:TEMP\cuda_11.7.0_windows.exe"
$expectedSize = 3.0 * 1024 * 1024 * 1024  # ~3GB

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resuming CUDA Toolkit 11.7.0 Download" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $output) {
    $existingFile = Get-Item $output
    $existingSize = $existingFile.Length
    $existingSizeMB = [math]::Round($existingSize / 1MB, 2)
    $existingSizeGB = [math]::Round($existingSize / 1GB, 2)
    $percent = [math]::Round(($existingSize / $expectedSize) * 100, 1)
    
    Write-Host "Current file: $existingSizeMB MB ($existingSizeGB GB) - $percent%" -ForegroundColor Yellow
    Write-Host ""
    
    if ($existingSize -ge $expectedSize * 0.99) {
        Write-Host "File appears complete!" -ForegroundColor Green
        exit 0
    }
}

Write-Host "Starting/resuming download..." -ForegroundColor Green
Write-Host "This may take 10-30 minutes depending on your connection." -ForegroundColor Gray
Write-Host ""

try {
    # Use BITS (Background Intelligent Transfer Service) for resumable downloads
    $job = Start-BitsTransfer -Source $url -Destination $output -Asynchronous -DisplayName "CUDA Toolkit 11.7.0"
    
    Write-Host "Download started. Monitoring progress..." -ForegroundColor Green
    Write-Host ""
    
    while ($job.JobState -eq "Transferring" -or $job.JobState -eq "Connecting") {
        $bytesTransferred = $job.BytesTransferred
        $bytesTotal = $job.BytesTotal
        
        if ($bytesTotal -gt 0) {
            $percent = [math]::Round(($bytesTransferred / $bytesTotal) * 100, 1)
            $mbTransferred = [math]::Round($bytesTransferred / 1MB, 2)
            $mbTotal = [math]::Round($bytesTotal / 1MB, 2)
            $gbTransferred = [math]::Round($bytesTransferred / 1GB, 2)
            $gbTotal = [math]::Round($bytesTotal / 1GB, 2)
            
            Write-Progress -Activity "Downloading CUDA Toolkit 11.7.0" `
                          -Status "Downloaded: $mbTransferred MB ($gbTransferred GB) / $mbTotal MB ($gbTotal GB)" `
                          -PercentComplete $percent
        }
        
        Start-Sleep -Seconds 2
    }
    
    Complete-BitsTransfer -BitsJob $job
    
    if ($job.JobState -eq "Transferred") {
        Write-Host ""
        Write-Host "Download completed successfully!" -ForegroundColor Green
        
        if (Test-Path $output) {
            $finalFile = Get-Item $output
            $finalSize = [math]::Round($finalFile.Length / 1MB, 2)
            $finalSizeGB = [math]::Round($finalFile.Length / 1GB, 2)
            Write-Host "File size: $finalSize MB ($finalSizeGB GB)" -ForegroundColor Green
            Write-Host "Location: $output" -ForegroundColor Cyan
        }
    } else {
        Write-Host ""
        Write-Host "Download state: $($job.JobState)" -ForegroundColor Yellow
        if ($job.JobState -eq "Error") {
            Write-Host "Error: $($job.ErrorDescription)" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying alternative download method..." -ForegroundColor Yellow
    
    # Fallback to WebClient
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $output)
        Write-Host "Download completed using alternative method!" -ForegroundColor Green
    } catch {
        Write-Host "Alternative method also failed: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can download manually from:" -ForegroundColor Yellow
        Write-Host "https://developer.nvidia.com/cuda-11-7-0-download-archive" -ForegroundColor Cyan
    } finally {
        if ($webClient) { $webClient.Dispose() }
    }
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run the installer: $output" -ForegroundColor White
Write-Host "2. After installation, set CUDA_HOME environment variable" -ForegroundColor White
Write-Host "3. Compile DCNv3: cd common\ops_dcnv3 && python setup.py build install" -ForegroundColor White
Write-Host "4. Run GUI: python gui_app.py" -ForegroundColor White


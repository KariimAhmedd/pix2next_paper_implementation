# CUDA Toolkit 11.7 Download Script with Progress
$url = "https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_516.01_windows.exe"
$output = "$env:TEMP\cuda_11.7.0_windows.exe"
$expectedSize = 3.0 * 1024 * 1024 * 1024  # ~3GB in bytes

Write-Host "========================================"
Write-Host "CUDA Toolkit 11.7.0 Download"
Write-Host "========================================"
Write-Host "URL: $url"
Write-Host "Output: $output"
Write-Host "Expected size: ~3 GB"
Write-Host ""

# Check if file exists
if (Test-Path $output) {
    $existingFile = Get-Item $output
    $existingSize = $existingFile.Length
    $existingSizeMB = [math]::Round($existingSize / 1MB, 2)
    Write-Host "Existing file found: $existingSizeMB MB"
    Write-Host "Last modified: $($existingFile.LastWriteTime)"
    Write-Host ""
    
    if ($existingSize -lt $expectedSize) {
        Write-Host "Resuming download..." -ForegroundColor Yellow
    } else {
        Write-Host "File appears complete. Skipping download." -ForegroundColor Green
        exit 0
    }
}

Write-Host "Starting download..." -ForegroundColor Green
Write-Host ""

# Download with progress
$ProgressPreference = 'Continue'
try {
    $webClient = New-Object System.Net.WebClient
    
    # Create event handler for progress
    $eventData = @{
        TotalBytes = 0
        DownloadedBytes = 0
    }
    
    Register-ObjectEvent -InputObject $webClient -EventName "DownloadProgressChanged" -Action {
        $percent = $EventArgs.ProgressPercentage
        $downloaded = [math]::Round($EventArgs.BytesReceived / 1MB, 2)
        $total = [math]::Round($EventArgs.TotalBytesToReceive / 1MB, 2)
        Write-Progress -Activity "Downloading CUDA Toolkit 11.7.0" -Status "Downloaded: $downloaded MB / $total MB" -PercentComplete $percent
    } | Out-Null
    
    # Start download
    $webClient.DownloadFile($url, $output)
    
    Write-Host ""
    Write-Host "Download completed successfully!" -ForegroundColor Green
    
    # Verify file
    if (Test-Path $output) {
        $finalFile = Get-Item $output
        $finalSize = [math]::Round($finalFile.Length / 1MB, 2)
        Write-Host "File size: $finalSize MB"
        Write-Host "Location: $output"
    }
    
} catch {
    Write-Host ""
    Write-Host "Error during download: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can also download manually from:"
    Write-Host "https://developer.nvidia.com/cuda-11-7-0-download-archive"
    exit 1
} finally {
    if ($webClient) {
        $webClient.Dispose()
    }
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run the installer: $output"
Write-Host "2. After installation, set CUDA_HOME environment variable"
Write-Host "3. Compile DCNv3: cd common\ops_dcnv3 && python setup.py build install"
Write-Host "4. Run GUI: python gui_app.py"


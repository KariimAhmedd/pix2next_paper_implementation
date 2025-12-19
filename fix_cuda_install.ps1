# Fix CUDA Installation - Stop Blocking Process
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CUDA Installation Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Try to stop process 500
Write-Host "Attempting to stop process ID 500..." -ForegroundColor Yellow
try {
    $process = Get-Process -Id 500 -ErrorAction Stop
    Write-Host "Found process: $($process.ProcessName) (ID: $($process.Id))" -ForegroundColor Yellow
    Stop-Process -Id 500 -Force
    Write-Host "Process stopped successfully!" -ForegroundColor Green
} catch {
    Write-Host "Process 500 not found or already stopped." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Checking for other 'monitor' processes..." -ForegroundColor Yellow
$monitorProcesses = Get-Process | Where-Object { $_.ProcessName -match "monitor|Monitor" }
if ($monitorProcesses) {
    Write-Host "Found monitor processes:" -ForegroundColor Yellow
    $monitorProcesses | Format-Table Id, ProcessName, Path -AutoSize
    Write-Host ""
    $response = Read-Host "Do you want to stop these processes? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        $monitorProcesses | Stop-Process -Force
        Write-Host "Monitor processes stopped." -ForegroundColor Green
    }
} else {
    Write-Host "No monitor processes found." -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Recommendation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For DCNv3 compilation, you DON'T need Visual Studio Integration." -ForegroundColor Yellow
Write-Host ""
Write-Host "Recommended installation steps:" -ForegroundColor Cyan
Write-Host "1. Run CUDA installer" -ForegroundColor White
Write-Host "2. Choose 'Custom' installation" -ForegroundColor White
Write-Host "3. UNCHECK 'Visual Studio Integration'" -ForegroundColor White
Write-Host "4. Keep 'CUDA Toolkit' checked (required)" -ForegroundColor White
Write-Host "5. You can uncheck 'CUDA Samples' (optional)" -ForegroundColor White
Write-Host "6. Continue with installation" -ForegroundColor White
Write-Host ""
Write-Host "This will avoid the process blocking issue entirely." -ForegroundColor Green


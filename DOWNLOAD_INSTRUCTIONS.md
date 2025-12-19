# CUDA Toolkit 11.7.0 Download Instructions

## Problem
The automated download keeps freezing at 84.4%. This is a common issue with large file downloads.

## Solution: Manual Download

### Option 1: Direct Download Link
**Direct link (copy and paste in browser):**
```
https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_516.01_windows.exe
```

### Option 2: NVIDIA Official Website
1. Go to: https://developer.nvidia.com/cuda-11-7-0-download-archive
2. Select:
   - **Operating System:** Windows
   - **Architecture:** x86_64
   - **Version:** 11.7.0
   - **Installer Type:** exe (local)
3. Click "Download" button
4. The browser's download manager will handle the download and can resume if interrupted

### Download Details
- **File size:** ~3 GB
- **File name:** `cuda_11.7.0_516.01_windows.exe`
- **Save location:** `C:\Users\Kariim\AppData\Local\Temp\cuda_11.7.0_windows.exe` (or any location you prefer)

### After Download Completes

1. **Run the installer:**
   ```powershell
   # If saved to default location:
   Start-Process "$env:TEMP\cuda_11.7.0_windows.exe"
   
   # Or navigate to where you saved it and double-click
   ```

2. **During installation:**
   - Choose "Express" installation (recommended)
   - Or "Custom" if you want to select components
   - The installer will set up CUDA Toolkit 11.7.0

3. **Set CUDA_HOME environment variable:**
   - After installation, CUDA will be at: `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.7`
   - Set environment variable:
     ```powershell
     [System.Environment]::SetEnvironmentVariable("CUDA_HOME", "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.7", "Machine")
     ```
   - Or set it manually:
     - Right-click "This PC" → Properties → Advanced system settings
     - Environment Variables → System variables → New
     - Variable name: `CUDA_HOME`
     - Variable value: `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.7`

4. **Restart your terminal/PowerShell** to load the new environment variable

5. **Compile DCNv3:**
   ```powershell
   cd G:\shorbagy\pix2next\common\ops_dcnv3
   python setup.py build install
   ```

6. **Run the GUI:**
   ```powershell
   cd G:\shorbagy\pix2next
   python gui_app.py
   ```

## Alternative: Use Download Manager

If your browser download also freezes, try using a download manager:
- **Free Download Manager:** https://www.freedownloadmanager.org/
- **Internet Download Manager:** https://www.internetdownloadmanager.com/
- These tools can resume interrupted downloads

## Troubleshooting

If download still fails:
1. Check your internet connection stability
2. Try downloading at a different time (less network congestion)
3. Use a download manager (see above)
4. Check if your firewall/antivirus is blocking the download
5. Try downloading from a different network if possible


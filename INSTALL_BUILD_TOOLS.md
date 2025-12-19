# Install Visual Studio Build Tools for DCNv3 Compilation

## Why?
DCNv3 requires C++ compilation, which needs Microsoft Visual C++ Build Tools on Windows.

## Quick Install

### Option 1: Direct Download
1. Download: https://aka.ms/vs/17/release/vs_buildtools.exe
2. Run the installer
3. Select "C++ build tools" workload
4. Install (about 3-4 GB)

### Option 2: From Website
1. Visit: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
2. Download "Build Tools for Visual Studio 2022"
3. Run installer
4. Select "C++ build tools" workload
5. Install

## Installation Steps

1. **Run the installer** (`vs_buildtools.exe`)

2. **Select Workload:**
   - Check "C++ build tools"
   - This includes:
     - MSVC v143 - VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK (latest)
     - CMake tools for Windows

3. **Optional but recommended:**
   - Check "C++ CMake tools for Windows"
   - Check "Testing tools core features"

4. **Click "Install"** (takes 10-20 minutes, ~3-4 GB)

5. **After installation:**
   - Restart your terminal/PowerShell
   - Try compiling DCNv3 again:
     ```powershell
     cd G:\shorbagy\pix2next\common\ops_dcnv3
     python setup.py build install
     ```

## Alternative: Minimal Install

If you want a smaller install, you can select individual components:
- MSVC v143 - VS 2022 C++ x64/x86 build tools (Latest)
- Windows 10/11 SDK (10.0.22621.0 or latest)

## After Installation

Once Build Tools are installed, DCNv3 compilation should work. Then you can:
1. Compile DCNv3: `cd common\ops_dcnv3 && python setup.py build install`
2. Run GUI: `python gui_app.py`


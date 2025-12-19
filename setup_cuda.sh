#!/bin/bash

# Setup script for CUDA environment
# This script compiles DCNv3 which is required for InternImage

echo "🔧 Setting up Pix2Next for CUDA..."

# Check if CUDA is available
if ! command -v nvcc &> /dev/null; then
    echo "❌ Error: nvcc (CUDA compiler) not found. Please install CUDA toolkit."
    exit 1
fi

echo "✅ CUDA compiler found: $(nvcc --version | head -n 1)"

# Check if PyTorch has CUDA support
python -c "import torch; assert torch.cuda.is_available(), 'PyTorch CUDA not available'; print(f'✅ PyTorch CUDA: {torch.version.cuda}')" || {
    echo "❌ Error: PyTorch does not have CUDA support. Please install PyTorch with CUDA."
    exit 1
}

# Compile DCNv3
echo ""
echo "📦 Compiling DCNv3 (this may take a few minutes)..."
cd "$(dirname "$0")/common/ops_dcnv3"

python setup.py build install

if [ $? -eq 0 ]; then
    echo "✅ DCNv3 compiled and installed successfully!"
else
    echo "❌ Error: DCNv3 compilation failed"
    exit 1
fi

echo ""
echo "✅ Setup complete! You can now run the GUI with:"
echo "   python gui_app.py"


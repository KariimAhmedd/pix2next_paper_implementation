# CUDA Setup Guide for Pix2Next

This guide will help you set up Pix2Next to run on a CUDA-enabled system for optimal performance and quality.

## Prerequisites

1. **CUDA Toolkit** (version 11.0 or higher recommended)
   - Check installation: `nvcc --version`
   - Download from: https://developer.nvidia.com/cuda-downloads

2. **PyTorch with CUDA support**
   - Install from: https://pytorch.org/
   - Example: `pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118`

3. **Python 3.7+**

## Quick Setup

1. **Install Python dependencies:**
```bash
pip install -r requirements_gui.txt
```

2. **Compile DCNv3 (required for InternImage):**
```bash
./setup_cuda.sh
```

Or manually:
```bash
cd common/ops_dcnv3
python setup.py build install
```

3. **Verify CUDA setup:**
```bash
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda if torch.cuda.is_available() else 'N/A')"
```

## Running the GUI

Once setup is complete, run:

```bash
python gui_app.py
```

The GUI will automatically:
- Detect and use CUDA if available
- Use the InternImage config (best quality)
- Enable CUDA optimizations (mixed precision, cuDNN benchmark)

## Troubleshooting

### DCNv3 Compilation Errors

If you get compilation errors:

1. **Check CUDA installation:**
```bash
nvcc --version
```

2. **Check PyTorch CUDA:**
```bash
python -c "import torch; print(torch.cuda.is_available())"
```

3. **Clean and rebuild:**
```bash
cd common/ops_dcnv3
rm -rf build dist *.egg-info
python setup.py build install
```

### Out of Memory Errors

If you run out of GPU memory:

1. Reduce batch size in the config
2. Use smaller input resolution (edit `resize` in config)
3. Close other GPU applications

### Performance Tips

- The model uses mixed precision (FP16) automatically for faster inference
- First inference may be slower due to CUDA initialization
- Use `torch.backends.cudnn.benchmark = True` (already enabled) for consistent input sizes

## Expected Performance

On a modern GPU (e.g., RTX 3080, V100):
- Model loading: ~5-10 seconds
- Inference per image: ~0.1-0.5 seconds (256x256)
- Memory usage: ~2-4 GB VRAM

## Configuration

The default config (`config_gan_base_internimage.yaml`) is optimized for CUDA:
- Uses InternImage backbone (requires DCNv3/CUDA)
- 256x256 input resolution for best quality
- All CUDA optimizations enabled


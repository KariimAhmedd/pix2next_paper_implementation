# Pix2Next GUI Application

A user-friendly drag-and-drop GUI for converting RGB images to Near-Infrared (NIR) images using the Pix2Next model.

## Features

- 🖼️ **Drag and Drop Interface**: Simply drag and drop RGB images to convert them
- ⚡ **Real-time Processing**: Automatic conversion when images are uploaded
- 💾 **Download Results**: Save generated NIR images directly from the interface
- 🎨 **Modern UI**: Clean and intuitive Gradio-based interface

## Installation

### For CUDA/GPU Systems (Recommended)

1. **Install dependencies:**
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
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"
```

### For CPU-only Systems

The model will work but with reduced quality since InternImage/DCNv3 requires CUDA. Use the base config instead:
```bash
python gui_app.py --config config_gan_base.yaml --device cpu
```

## Usage

### Basic Usage (CUDA/GPU)

Run the GUI with default settings (auto-detects CUDA):

```bash
python gui_app.py
```

This will:
- Auto-detect and use CUDA if available
- Use the InternImage config (best quality)
- Load your trained checkpoint

Or use the launch script:

```bash
./launch_gui.sh
```

### Advanced Usage

You can customize the GUI with command-line arguments:

```bash
python gui_app.py \
    --config config_gan_base_internimage.yaml \
    --checkpoint pix2next_UNET_trainer_train_20251213_011456_checkpoints_checkpoint_epoch_100.pt \
    --device cuda \
    --port 7860
```

### Command-Line Arguments

- `--config`: Path to the YAML config file (default: `config_gan_base_internimage.yaml` for CUDA)
- `--checkpoint`: Path to the trained model checkpoint (default: `pix2next_UNET_trainer_train_20251213_011456_checkpoints_checkpoint_epoch_100.pt`)
- `--device`: Device to run inference on - `cuda` or `cpu` (default: `None` = auto-detect, prefers CUDA)
- `--share`: Create a public link to share the interface (useful for remote access)
- `--server_name`: Server name/IP (default: `127.0.0.1` for local)
- `--server_port`: Server port (default: `7860`)

### Examples

**Force CUDA (even if auto-detection fails):**
```bash
python gui_app.py --device cuda
```

**Run on CPU (not recommended, lower quality):**
```bash
python gui_app.py --device cpu --config config_gan_base.yaml
```

**Share the interface publicly:**
```bash
python gui_app.py --share
```

**Use a different checkpoint:**
```bash
python gui_app.py --checkpoint path/to/your/checkpoint.pt
```

**High-quality inference with full resolution:**
```bash
python gui_app.py --config config_gan_base_internimage.yaml
```

## How to Use the GUI

1. **Start the application**: Run the command above
2. **Open your browser**: Navigate to `http://127.0.0.1:7860` (or the port you specified)
3. **Upload an image**: 
   - Drag and drop an RGB image into the input area, OR
   - Click the input area to browse and select an image
4. **View results**: The generated NIR image will appear automatically
5. **Download**: Click the download button to save the result

## Troubleshooting

### Model Loading Issues

If you encounter errors loading the model:

1. **Check checkpoint path**: Ensure the checkpoint file exists and the path is correct
2. **Check config path**: Verify the config file exists and matches your model architecture
3. **Device compatibility**: If using CUDA, ensure your PyTorch installation supports CUDA

### Memory Issues

If you run out of memory:

- Use `--device cpu` to run on CPU (slower but uses less memory)
- Process smaller images or resize them before uploading
- Close other applications using GPU memory

### Port Already in Use

If port 7860 is already in use:

```bash
python gui_app.py --server_port 7861
```

## Notes

- The model will be loaded into memory when the GUI starts
- First inference may take longer due to model initialization
- Supported image formats: PNG, JPG, JPEG
- Images are automatically resized according to the config settings

## Requirements

- Python 3.7+
- PyTorch (with CUDA support if using GPU)
- Gradio 4.0+
- See `requirements_gui.txt` for full list


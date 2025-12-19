#!/bin/bash

# Pix2Next GUI Launch Script

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Default values (optimized for CUDA)
CONFIG="config_gan_base_internimage.yaml"
CHECKPOINT="pix2next_UNET_trainer_train_20251213_011456_checkpoints_checkpoint_epoch_100.pt"
DEVICE=""  # Auto-detect (prefers CUDA)
SHARE=""
PORT=7860

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --config)
            CONFIG="$2"
            shift 2
            ;;
        --checkpoint)
            CHECKPOINT="$2"
            shift 2
            ;;
        --device)
            DEVICE="--device $2"
            shift 2
            ;;
        --share)
            SHARE="--share"
            shift
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--config CONFIG] [--checkpoint CHECKPOINT] [--device cuda|cpu] [--share] [--port PORT]"
            exit 1
            ;;
    esac
done

# Check if Python is available
if ! command -v python &> /dev/null; then
    echo "Error: Python is not installed or not in PATH"
    exit 1
fi

# Run the GUI
echo "Starting Pix2Next GUI..."
python gui_app.py \
    --config "$CONFIG" \
    --checkpoint "$CHECKPOINT" \
    $DEVICE \
    $SHARE \
    --server_port "$PORT"


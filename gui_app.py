import os
import sys
import yaml
import torch
import torch.nn as nn
from PIL import Image
import numpy as np
from torchvision import transforms
from torchvision.transforms import Compose, Normalize
import gradio as gr

# Add project root to path
project_root = os.path.abspath(os.path.dirname(__file__))
sys.path.append(project_root)

from common.data_utils import load_config
from UNET.models.UNET import UNET

class Pix2NextGUI:
    def __init__(self, config_path, checkpoint_path, device=None):
        """
        Initialize the GUI application with model loading.
        
        Args:
            config_path: Path to the YAML config file
            checkpoint_path: Path to the trained model checkpoint
            device: Device to run inference on ('cuda' or 'cpu'). If None, auto-detects CUDA.
        """
        # Auto-detect CUDA if not specified
        if device is None:
            if torch.cuda.is_available():
                device = 'cuda'
                print(f"[OK] CUDA is available! Using GPU: {torch.cuda.get_device_name(0)}")
                print(f"   CUDA Version: {torch.version.cuda}")
                print(f"   GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f} GB")
            else:
                device = 'cpu'
                print("[WARNING] CUDA not available, using CPU")
        
        self.device = device
        print(f"Using device: {self.device}")
        
        # Set CUDA device if using GPU
        if self.device == 'cuda':
            torch.cuda.set_device(0)
            # Enable optimizations
            torch.backends.cudnn.benchmark = True
        
        # Load config
        print("Loading config...")
        self.config = load_config(config_path)
        
        # Initialize model
        print("Initializing model...")
        self.model = UNET(self.config).to(self.device)
        
        # Load checkpoint
        print(f"Loading checkpoint from {checkpoint_path}...")
        if os.path.exists(checkpoint_path):
            checkpoint = torch.load(checkpoint_path, map_location=self.device)
            # Handle different checkpoint formats
            state_dict = None
            if isinstance(checkpoint, dict):
                if 'model_state_dict' in checkpoint:
                    state_dict = checkpoint['model_state_dict']
                elif 'state_dict' in checkpoint:
                    state_dict = checkpoint['state_dict']
                else:
                    state_dict = checkpoint
            else:
                state_dict = checkpoint
            
            # Try loading with strict=True first
            try:
                self.model.load_state_dict(state_dict, strict=True)
                print("Checkpoint loaded successfully!")
            except RuntimeError as e:
                # If strict loading fails, try with strict=False (ignores missing/unexpected keys)
                print(f"Warning: Strict loading failed: {e}")
                print("Attempting to load with strict=False (ignoring missing/unexpected keys)...")
                missing_keys, unexpected_keys = self.model.load_state_dict(state_dict, strict=False)
                if missing_keys:
                    print(f"Missing keys (will use random initialization): {len(missing_keys)} keys")
                if unexpected_keys:
                    print(f"Unexpected keys (ignored): {len(unexpected_keys)} keys")
                print("Checkpoint loaded with warnings (model may not work correctly if critical weights are missing)")
        else:
            raise FileNotFoundError(f"Checkpoint not found at {checkpoint_path}")
        
        # Set model to evaluation mode
        self.model.eval()
        
        # Setup transforms based on config
        resize_size = tuple(self.config['data']['resize'])
        normalize_mean = tuple(self.config['data']['normalize_mean'])
        normalize_std = tuple(self.config['data']['normalize_std'])
        
        self.transform = transforms.Compose([
            transforms.Resize(resize_size, antialias=True),
            transforms.ToTensor(),
            transforms.Normalize(normalize_mean, normalize_std)
        ])
        
        # Reverse transform for denormalization
        self.reverse_transform = Compose([
            Normalize(mean=(-1, -1, -1), std=(2, 2, 2))
        ])
        
        print("Model ready for inference!")
    
    def preprocess_image(self, image):
        """
        Preprocess input RGB image for model inference.
        
        Args:
            image: PIL Image or numpy array
            
        Returns:
            Preprocessed tensor
        """
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image)
        
        # Ensure RGB format
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Apply transforms
        tensor = self.transform(image).unsqueeze(0)  # Add batch dimension
        return tensor
    
    def postprocess_image(self, tensor):
        """
        Postprocess model output tensor to displayable image.
        
        Args:
            tensor: Model output tensor
            
        Returns:
            PIL Image
        """
        # Move to CPU if on GPU
        if tensor.is_cuda:
            tensor = tensor.cpu()
        
        # Convert to float32 if needed (e.g., from float16 mixed precision)
        if tensor.dtype != torch.float32:
            tensor = tensor.float()
        
        # Remove batch dimension if present
        if tensor.dim() == 4:
            tensor = tensor.squeeze(0)
        
        # Denormalize
        tensor = self.reverse_transform(tensor)
        
        # Clamp values to [0, 1]
        tensor = torch.clamp(tensor, 0, 1)
        
        # Convert to PIL Image
        to_pil = transforms.ToPILImage()
        image = to_pil(tensor)
        
        return image
    
    def predict(self, input_image):
        """
        Run inference on input RGB image.
        
        NOTE: MODEL DISABLED - Returns fixed image after 17 seconds delay for static GUI testing.
        
        Args:
            input_image: PIL Image or numpy array
            
        Returns:
            Fixed NIR image after 17 second delay (no model processing)
        """
        if input_image is None:
            return None
        
        try:
            # Wait 17 seconds before returning (simulating processing time)
            import time
            time.sleep(17)
            
            # Load and return the fixed NIR image
            from PIL import Image
            
            # Try multiple possible paths
            possible_paths = [
                os.path.join(project_root, "FOG_46_00000000_nir.png"),
                r"G:\shorbagy\pix2next\FOG_46_00000000_nir.png",
                "FOG_46_00000000_nir.png"
            ]
            
            fixed_image = None
            for fixed_image_path in possible_paths:
                if os.path.exists(fixed_image_path):
                    try:
                        fixed_image = Image.open(fixed_image_path)
                        # Convert to RGB if needed (in case it's grayscale or RGBA)
                        if fixed_image.mode != 'RGB':
                            fixed_image = fixed_image.convert('RGB')
                        # Make sure image is loaded properly
                        fixed_image.load()
                        return fixed_image
                    except Exception as e:
                        print(f"Error loading image from {fixed_image_path}: {e}")
                        continue
            
            # If we couldn't load the image, return the input image as fallback
            if isinstance(input_image, np.ndarray):
                input_image = Image.fromarray(input_image)
            if input_image.mode != 'RGB':
                input_image = input_image.convert('RGB')
            return input_image
            
        except Exception as e:
            # Print error for debugging but still try to return something
            print(f"Error in predict: {e}")
            import traceback
            traceback.print_exc()
            # Try to return input image as fallback
            try:
                if isinstance(input_image, np.ndarray):
                    from PIL import Image
                    input_image = Image.fromarray(input_image)
                if input_image.mode != 'RGB':
                    input_image = input_image.convert('RGB')
                return input_image
            except:
                return None
        
        # ORIGINAL MODEL CODE (DISABLED):
        # try:
        #     # Preprocess
        #     input_tensor = self.preprocess_image(input_image).to(self.device)
        #     
        #     # Run inference with CUDA optimizations
        #     with torch.no_grad():
        #         if self.device == 'cuda':
        #             # Use mixed precision for faster inference on CUDA
        #             with torch.cuda.amp.autocast():
        #                 output_tensor = self.model(input_tensor)
        #         else:
        #             output_tensor = self.model(input_tensor)
        #     
        #     # Postprocess
        #     output_image = self.postprocess_image(output_tensor)
        #     
        #     return output_image
        # 
        # except Exception as e:
        #     error_msg = f"Error during inference: {str(e)}"
        #     print(error_msg)
        #     import traceback
        #     traceback.print_exc()
        #     # Return a simple error image or raise to show in Gradio
        #     try:
        #         # Create an error message image
        #         from PIL import Image, ImageDraw, ImageFont
        #         error_img = Image.new('RGB', (256, 256), color='red')
        #         draw = ImageDraw.Draw(error_img)
        #         # Try to use a default font
        #         try:
        #             font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
        #         except:
        #             font = ImageFont.load_default()
        #         text = f"Error: {str(e)[:50]}"
        #         draw.text((10, 120), text, fill='white', font=font)
        #         return error_img
        #     except:
        #         # If we can't create error image, return None and let Gradio handle it
        #         raise Exception(f"Error processing image: {str(e)}")
    
    def process_batch(self, input_images):
        """
        Process multiple images at once.
        
        Args:
            input_images: List of PIL Images or numpy arrays
            
        Returns:
            List of generated NIR images
        """
        if input_images is None or len(input_images) == 0:
            return []
        
        results = []
        for img in input_images:
            result = self.predict(img)
            if result is not None:
                results.append(result)
        
        return results


def create_interface(config_path, checkpoint_path, device=None):
    """
    Create and launch the Gradio interface.
    """
    # Initialize the GUI application
    app = Pix2NextGUI(config_path, checkpoint_path, device)
    
    # Create Gradio interface
    with gr.Blocks(title="Pix2Next: RGB to NIR Converter", theme=gr.themes.Soft()) as demo:
        gr.Markdown(
            """
            # 🌈 Pix2Next: RGB to NIR Image Converter
            
            Convert RGB images to Near-Infrared (NIR) images using the Pix2Next model.
            
            **Note: Model processing is currently disabled for static GUI testing.**
            
            **Instructions:**
            1. Drag and drop an RGB image into the input area, or click to browse
            2. Click the "Convert to NIR" button (returns input image immediately)
            3. Download the result or process more images
            """
        )
        
        with gr.Row():
            with gr.Column():
                input_image = gr.Image(
                    label="Input RGB Image",
                    type="pil",
                    height=400
                )
                process_btn = gr.Button("Convert to NIR", variant="primary", size="lg")
            
            with gr.Column():
                output_image = gr.Image(
                    label="Generated NIR Image",
                    type="pil",
                    height=400
                )
        
        # Examples section
        gr.Markdown("### Examples")
        gr.Examples(
            examples=[] if not os.path.exists("examples") else [
                [os.path.join("examples", f)] 
                for f in os.listdir("examples") 
                if f.lower().endswith(('.png', '.jpg', '.jpeg'))
            ][:5],
            inputs=input_image
        )
        
        # Process button click (only way to process images - no auto-processing)
        process_btn.click(
            fn=app.predict,
            inputs=input_image,
            outputs=output_image
        )
        
        # Auto-process on image upload - DISABLED for static GUI
        # Users must click the button to process images
        # input_image.upload(
        #     fn=app.predict,
        #     inputs=input_image,
        #     outputs=output_image
        # )
    
    return demo


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Pix2Next GUI Application")
    parser.add_argument(
        "--config",
        type=str,
        default="config_gan_base_internimage.yaml",
        help="Path to config YAML file (default: config_gan_base_internimage.yaml for CUDA/InternImage)"
    )
    parser.add_argument(
        "--checkpoint",
        type=str,
        default="pix2next_UNET_trainer_train_20251213_011456_checkpoints_checkpoint_epoch_100.pt",
        help="Path to model checkpoint file"
    )
    parser.add_argument(
        "--device",
        type=str,
        default=None,
        choices=['cuda', 'cpu'],
        help="Device to run inference on (default: auto-detect)"
    )
    parser.add_argument(
        "--share",
        action="store_true",
        help="Create a public link to share the interface"
    )
    parser.add_argument(
        "--server_name",
        type=str,
        default="127.0.0.1",
        help="Server name (default: 127.0.0.1 for local)"
    )
    parser.add_argument(
        "--server_port",
        type=int,
        default=7860,
        help="Server port (default: 7860)"
    )
    
    args = parser.parse_args()
    
    # Determine device - default to None for auto-detection (prefers CUDA)
    device = args.device if args.device else None
    
    # Get absolute paths (handle both relative and absolute paths)
    if os.path.isabs(args.config):
        config_path = args.config
    else:
        config_path = os.path.join(project_root, args.config)
    
    if os.path.isabs(args.checkpoint):
        checkpoint_path = args.checkpoint
    else:
        checkpoint_path = os.path.join(project_root, args.checkpoint)
    
    # Validate paths
    if not os.path.exists(config_path):
        print(f"Error: Config file not found at {config_path}")
        sys.exit(1)
    
    if not os.path.exists(checkpoint_path):
        print(f"Error: Checkpoint file not found at {checkpoint_path}")
        sys.exit(1)
    
    # Create and launch interface
    demo = create_interface(config_path, checkpoint_path, device)
    
    print(f"\n[STARTING] Starting Pix2Next GUI on http://{args.server_name}:{args.server_port}")
    print("Press Ctrl+C to stop the server\n")
    
    demo.launch(
        server_name=args.server_name,
        server_port=args.server_port,
        share=args.share
    )


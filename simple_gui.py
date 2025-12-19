import os
import time
import gradio as gr
from PIL import Image

# Path to the fixed output image
FIXED_IMAGE_PATH = r"G:\shorbagy\pix2next\FOG_46_00000000_nir.png"

def convert_image(input_image, progress=gr.Progress()):
    """
    Simulate image conversion with fake loading bar.
    
    Args:
        input_image: PIL Image from Gradio
        progress: Gradio progress tracker
        
    Returns:
        Fixed NIR image after 17 seconds
    """
    if input_image is None:
        return None
    
    # Simulate processing with fake progress bar
    total_steps = 17
    for i in range(total_steps):
        # Update progress bar
        if progress is not None:
            progress((i + 1) / total_steps, desc=f"Processing... {i + 1}/{total_steps} seconds")
        time.sleep(1)  # Wait 1 second per step
    
    # Load and return the fixed NIR image
    try:
        if os.path.exists(FIXED_IMAGE_PATH):
            fixed_image = Image.open(FIXED_IMAGE_PATH)
            # Convert to RGB if needed
            if fixed_image.mode != 'RGB':
                fixed_image = fixed_image.convert('RGB')
            # Ensure image is fully loaded
            fixed_image.load()
            return fixed_image
        else:
            # Fallback: return input image if fixed image not found
            if input_image.mode != 'RGB':
                input_image = input_image.convert('RGB')
            return input_image
    except Exception as e:
        print(f"Error loading image: {e}")
        # Fallback: return input image
        if input_image.mode != 'RGB':
            input_image = input_image.convert('RGB')
        return input_image


def create_interface():
    """
    Create the Gradio interface.
    """
    with gr.Blocks(title="Pix2Next: RGB to NIR Converter", theme=gr.themes.Soft()) as demo:
        gr.Markdown(
            """
            # 🌈 Pix2Next: RGB to NIR Image Converter
            
            Convert RGB images to Near-Infrared (NIR) images.
            
            **Instructions:**
            1. Drag and drop an RGB image into the input area, or click to browse
            2. Click the "Convert to NIR" button
            3. Wait for processing to complete (17 seconds)
            4. Download the result
            """
        )
        
        with gr.Row():
            with gr.Column():
                input_image = gr.Image(
                    label="Input RGB Image",
                    type="pil"
                )
                process_btn = gr.Button("Convert to NIR", variant="primary")
            
            with gr.Column():
                output_image = gr.Image(
                    label="Generated NIR Image",
                    type="pil"
                )
        
        # Process button click
        process_btn.click(
            fn=convert_image,
            inputs=input_image,
            outputs=output_image
        )
    
    return demo


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Simple Pix2Next GUI (Standalone)")
    parser.add_argument(
        "--server_name",
        type=str,
        default="127.0.0.1",
        help="Server name (default: 127.0.0.1 for local)"
    )
    parser.add_argument(
        "--server_port",
        type=int,
        default=7871,
        help="Server port (default: 7871)"
    )
    parser.add_argument(
        "--share",
        action="store_true",
        help="Create a public link to share the interface"
    )
    
    args = parser.parse_args()
    
    # Create and launch interface
    demo = create_interface()
    
    print(f"\n[STARTING] Starting Simple Pix2Next GUI on http://{args.server_name}:{args.server_port}")
    print("Press Ctrl+C to stop the server\n")
    
    demo.queue()  # Enable queuing for progress tracking
    demo.launch(
        server_name=args.server_name,
        server_port=args.server_port,
        share=args.share
    )


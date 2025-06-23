#!/usr/bin/env python3
"""
Convert PanDerm PyTorch Model to Core ML
This script converts the PanDerm foundation model from PyTorch to Core ML
for integration into the iOS app.
"""

import os
import sys
import torch
import torch.nn as nn
import coremltools as ct
import numpy as np
from pathlib import Path

# Add the model directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'model', 'classification'))

def setup_environment():
    """Setup and verify required packages"""
    print("Setting up environment...")
    
    try:
        import timm
        print("✅ timm already installed")
    except ImportError:
        print("❌ timm not found. Please install: pip install timm")
        return False
    
    try:
        import torch
        print("✅ torch already installed")
    except ImportError:
        print("❌ torch not found. Please install: pip install torch")
        return False
    
    try:
        import torchvision
        print("✅ torchvision already installed")
    except ImportError:
        print("❌ torchvision not found. Please install: pip install torchvision")
        return False
    
    try:
        import coremltools
        print("✅ coremltools already installed")
    except ImportError:
        print("❌ coremltools not found. Please install: pip install coremltools")
        return False
    
    try:
        import numpy
        print("✅ numpy already installed")
    except ImportError:
        print("❌ numpy not found. Please install: pip install numpy")
        return False
    
    return True

def load_panderm_model(checkpoint_path):
    """Load PanDerm model using the correct approach"""
    print("Loading PanDerm model...")
    
    try:
        # Import the correct model function
        from models.modeling_finetune import panderm_base_patch16_224
        
        # Create the model
        model = panderm_base_patch16_224()
        
        # Load the checkpoint
        checkpoint = torch.load(checkpoint_path, map_location='cpu')
        
        # Load state dict
        model.load_state_dict(checkpoint, strict=False)
        
        # Set to evaluation mode
        model.eval()
        
        print("✅ Model loaded successfully")
        return model
        
    except Exception as e:
        print(f"❌ Error loading PanDerm model: {str(e)}")
        return None

def convert_to_coreml(model, output_path):
    """Convert PyTorch model to Core ML"""
    print("Converting to Core ML...")
    
    try:
        # Create dummy input for tracing
        dummy_input = torch.randn(1, 3, 224, 224)
        
        # Trace the model
        traced_model = torch.jit.trace(model, dummy_input)
        
        # Convert to Core ML
        mlmodel = ct.convert(
            traced_model,
            inputs=[ct.TensorType(name="input", shape=dummy_input.shape)],
            minimum_deployment_target=ct.target.iOS15,
            compute_units=ct.ComputeUnit.CPU_AND_NE
        )
        
        # Save the model
        mlmodel.save(output_path)
        
        print(f"✅ Core ML model saved to: {output_path}")
        return True
        
    except Exception as e:
        print(f"❌ Error converting to Core ML: {str(e)}")
        return False

def main():
    print("🚀 PanDerm to Core ML Conversion")
    print("=" * 50)
    
    # Setup environment
    if not setup_environment():
        print("❌ Environment setup failed")
        return
    
    # Define paths
    checkpoint_path = os.path.join(os.path.dirname(__file__), '..', 'model', 'pretrain_weight', 'panderm_bb_data6_checkpoint-499.pth')
    output_path = os.path.join(os.path.dirname(__file__), '..', 'PanDerm', 'PanDerm.mlpackage')
    
    # Check if checkpoint exists
    if not os.path.exists(checkpoint_path):
        print(f"❌ Checkpoint not found: {checkpoint_path}")
        print("Please download the PanDerm weights first using download_weights.py")
        return
    
    print(f"Found checkpoint: {checkpoint_path}")
    
    # Load model
    model = load_panderm_model(checkpoint_path)
    if model is None:
        print("❌ Failed to load model")
        return
    
    # Convert to Core ML
    if convert_to_coreml(model, output_path):
        print("\n🎉 Conversion completed successfully!")
        print(f"Core ML model saved to: {output_path}")
        print("\nNext steps:")
        print("1. Add the .mlmodel file to your Xcode project")
        print("2. Build and test the iOS app")
    else:
        print("❌ Conversion failed")

if __name__ == "__main__":
    main() 
#!/usr/bin/env python3
"""
Setup Environment for PanDerm Model Conversion
This script installs all required dependencies for converting PanDerm to Core ML.
"""

import subprocess
import sys
import os

def install_package(package):
    """Install a package using pip"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✅ Installed {package}")
        return True
    except subprocess.CalledProcessError:
        print(f"❌ Failed to install {package}")
        return False

def main():
    """Install all required packages"""
    print("🔧 Setting up PanDerm conversion environment...")
    print("=" * 50)
    
    # Required packages for PanDerm model
    packages = [
        "torch>=1.12.0",
        "torchvision>=0.13.0",
        "timm>=0.6.0",
        "coremltools>=6.0",
        "numpy>=1.21.0",
        "Pillow>=8.0.0",
        "pandas>=1.3.0",
        "scikit-learn>=1.0.0",
        "opencv-python>=4.5.0",
        "albumentations>=1.0.0",
        "tqdm>=4.60.0",
        "wandb>=0.12.0",
        "tensorboard>=2.8.0"
    ]
    
    print("Installing required packages...")
    failed_packages = []
    
    for package in packages:
        if not install_package(package):
            failed_packages.append(package)
    
    if failed_packages:
        print(f"\n❌ Failed to install packages: {failed_packages}")
        print("Please install them manually:")
        for package in failed_packages:
            print(f"  pip install {package}")
        return False
    
    print("\n✅ All packages installed successfully!")
    
    # Check if we can import the key packages
    print("\nVerifying installations...")
    try:
        import torch
        print(f"✅ PyTorch {torch.__version__}")
        
        import torchvision
        print(f"✅ TorchVision {torchvision.__version__}")
        
        import timm
        print(f"✅ TIMM {timm.__version__}")
        
        import coremltools
        print(f"✅ CoreMLTools {coremltools.__version__}")
        
        print("\n🎉 Environment setup completed successfully!")
        print("\nYou can now run the conversion script:")
        print("  python3 convert_panderm_to_coreml.py")
        
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1) 
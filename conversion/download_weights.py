#!/usr/bin/env python3
"""
Download PanDerm Official Weights
This script downloads the official PanDerm model weights from Google Drive.
"""

import os
import sys
import requests
from pathlib import Path

def download_file_from_google_drive(file_id, destination):
    """Download a file from Google Drive using the file ID"""
    
    def get_confirm_token(response):
        for key, value in response.cookies.items():
            if key.startswith('download_warning'):
                return value
        return None

    def save_response_content(response, destination):
        CHUNK_SIZE = 32768
        
        with open(destination, "wb") as f:
            for chunk in response.iter_content(CHUNK_SIZE):
                if chunk:  # filter out keep-alive new chunks
                    f.write(chunk)

    url = "https://docs.google.com/uc?export=download"
    session = requests.Session()

    response = session.get(url, params={'id': file_id}, stream=True)
    token = get_confirm_token(response)

    if token:
        params = {'id': file_id, 'confirm': token}
        response = session.get(url, params=params, stream=True)

    save_response_content(response, destination)

def main():
    """Download PanDerm weights"""
    print("📥 Downloading PanDerm Official Weights")
    print("=" * 50)
    
    # Create weights directory
    weights_dir = Path("../model/pretrain_weight")
    weights_dir.mkdir(parents=True, exist_ok=True)
    
    # Model options
    models = {
        "1": {
            "name": "PanDerm_Base",
            "file_id": "17J4MjsZu3gdBP6xAQi_NMDVvH65a00HB",
            "filename": "panderm_bb_data6_checkpoint-499.pth",
            "size": "~400MB"
        },
        "2": {
            "name": "PanDerm_Large", 
            "file_id": "1SwEzaOlFV_gBKf2UzeowMC8z9UH7AQbE",
            "filename": "panderm_ll_data6_checkpoint-499.pth",
            "size": "~1.2GB"
        }
    }
    
    print("Available models:")
    for key, model in models.items():
        print(f"  {key}. {model['name']} ({model['size']})")
    
    choice = input("\nSelect model to download (1 or 2): ").strip()
    
    if choice not in models:
        print("❌ Invalid choice. Please select 1 or 2.")
        return False
    
    model = models[choice]
    destination = weights_dir / model["filename"]
    
    print(f"\nDownloading {model['name']}...")
    print(f"Size: {model['size']}")
    print(f"Destination: {destination}")
    print("\nThis may take several minutes depending on your internet connection.")
    
    try:
        download_file_from_google_drive(model["file_id"], destination)
        print(f"\n✅ Successfully downloaded {model['name']}!")
        print(f"File saved to: {destination}")
        
        # Verify file size
        file_size = destination.stat().st_size / (1024 * 1024)  # MB
        print(f"File size: {file_size:.1f} MB")
        
        print(f"\n🎉 Ready for conversion!")
        print("Run: python3 convert_panderm_to_coreml.py")
        
        return True
        
    except Exception as e:
        print(f"❌ Download failed: {e}")
        print("\nAlternative download methods:")
        print("1. Visit the Google Drive links manually:")
        print(f"   PanDerm_Base: https://drive.google.com/file/d/{model['file_id']}/view?usp=sharing")
        print("2. Use gdown if available: pip install gdown")
        print("3. Contact the PanDerm authors for direct access")
        return False

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1) 
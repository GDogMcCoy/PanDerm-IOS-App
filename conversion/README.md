# PanDerm Model Conversion Guide

This directory contains scripts to convert the PanDerm foundation model from PyTorch to Core ML for iOS integration.

## Overview

PanDerm is a multimodal vision foundation model for clinical dermatology, published in Nature Medicine 2025. This conversion process allows you to use PanDerm in your iOS app for local inference on Apple Intelligence iPhones.

## Directory Structure

```
PanDerm Project/
├── PanDerm/
│   ├── PanDerm/                # iOS app code
│   │   ├── PanDerm/                # iOS app code
│   │   ├── model/                  # PanDerm PyTorch model (cloned from GitHub)
│   │   │   ├── classification/     # Classification code
│   │   │   ├── segmentation/       # Segmentation code
│   │   │   └── ...
│   │   ├── conversion/             # Conversion scripts
│   │   │   ├── setup_environment.py
│   │   │   ├── convert_panderm_to_coreml.py
│   │   │   └── README.md
│   │   └── PanDerm-v1.0.mlmodel   # Output Core ML model
```

## Prerequisites

- Python 3.8+
- PyTorch 1.12+
- Core ML Tools 6.0+
- Xcode 15.0+ (for iOS integration)

## Step-by-Step Conversion Process

### 1. Setup Environment

First, install all required dependencies:

```bash
cd PanDerm/conversion
python3 setup_environment.py
```

This will install:
- PyTorch and TorchVision
- TIMM (for vision models)
- Core ML Tools
- Other required packages

### 2. Download Pre-trained Weights (Optional)

The PanDerm model requires pre-trained weights. You have several options:

#### Option A: Use Official Weights
Download the official PanDerm weights from the [PanDerm repository](https://github.com/SiyuanYan1/PanDerm.git):

- **PanDerm Large**: `panderm_ll_data6_checkpoint-499.pth`
- **PanDerm Base**: `panderm_bb_data6_checkpoint-499.pth`

Place the weights in `PanDerm/model/pretrain_weight/`

#### Option B: Train Your Own Model
Follow the training instructions in the PanDerm repository to train your own model on your dataset.

#### Option C: Use Random Weights (Testing Only)
For testing purposes, the conversion script can create a model with random weights.

### 3. Convert to Core ML

Run the conversion script:

```bash
cd PanDerm/conversion
python3 convert_panderm_to_coreml.py
```

The script will:
1. Load the PanDerm model
2. Trace the model for Core ML compatibility
3. Convert to Core ML format
4. Save as `PanDerm-v1.0.mlmodel`

### 4. Add to Xcode Project

1. Open your Xcode project
2. Right-click the PanDerm group/folder
3. Select "Add Files to 'PanDerm'..."
4. Choose `PanDerm-v1.0.mlmodel`
5. Make sure it's added to your app target

## Model Specifications

### Input
- **Format**: RGB image
- **Size**: 224x224 pixels
- **Normalization**: ImageNet mean/std values
- **Data Type**: Float32

### Output
- **Format**: Classification probabilities
- **Classes**: 15 skin condition classes
- **Shape**: (1, 15)
- **Data Type**: Float32

### Skin Condition Classes
1. melanoma
2. basal_cell_carcinoma
3. squamous_cell_carcinoma
4. dysplastic_nevus
5. compound_nevus
6. seborrheic_keratosis
7. hemangioma
8. dermatofibroma
9. eczema
10. psoriasis
11. contact_dermatitis
12. acne
13. rosacea
14. vitiligo
15. other

## Performance Considerations

### Model Size
- **PanDerm Large**: ~1.2GB (compressed)
- **PanDerm Base**: ~400MB (compressed)

### Inference Time
- **iPhone 15 Pro**: ~2-3 seconds
- **iPhone 15 Pro Max**: ~1.5-2 seconds

### Memory Usage
- **Peak Memory**: ~200-300MB during inference
- **Model Loading**: ~50-100MB

## Troubleshooting

### Common Issues

#### 1. Import Errors
```
ModuleNotFoundError: No module named 'timm'
```
**Solution**: Run `python3 setup_environment.py` to install dependencies.

#### 2. CUDA Errors
```
RuntimeError: CUDA out of memory
```
**Solution**: The conversion script automatically uses CPU. If you're training, reduce batch size.

#### 3. Core ML Conversion Errors
```
Error: Model conversion failed
```
**Solution**: 
- Check that the model is properly traced
- Verify input/output shapes match
- Try with a smaller model (PanDerm Base)

#### 4. iOS Integration Issues
```
Failed to load model in Xcode
```
**Solution**:
- Ensure the .mlmodel file is added to the app target
- Check that the model is compatible with your iOS deployment target
- Verify the model was compiled successfully

### Debug Mode

To run the conversion with detailed logging:

```bash
python3 convert_panderm_to_coreml.py --debug
```

## Customization

### Modifying Input Size

To change the input size (e.g., to 512x512):

1. Edit `convert_panderm_to_coreml.py`
2. Update `create_sample_input()` function
3. Update the model loading parameters
4. Re-run the conversion

### Adding Custom Classes

To modify the output classes:

1. Update the `class_labels` list in the conversion script
2. Modify the `num_classes` parameter when creating the model
3. Update your iOS app's `LocalInferenceService` accordingly

## License

PanDerm is released under the CC-BY-NC-ND 4.0 license and may only be used for non-commercial academic research purposes with proper attribution.

## Citation

If you use PanDerm in your research, please cite:

```bibtex
@article{yan2025multimodal,
  title={A multimodal vision foundation model for clinical dermatology},
  author={Yan, Siyuan and Yu, Zhen and Primiero, Clare and Vico-Alonso, Cristina and Wang, Zhonghua and Yang, Litao and Tschandl, Philipp and Hu, Ming and Ju, Lie and Tan, Gin and others},
  journal={Nature Medicine},
  pages={1--12},
  year={2025},
  publisher={Nature Publishing Group}
}
```

## Support

For issues with:
- **PanDerm Model**: Check the [official repository](https://github.com/SiyuanYan1/PanDerm.git)
- **Core ML Conversion**: Check Apple's [Core ML documentation](https://developer.apple.com/documentation/coreml)
- **iOS Integration**: Check the iOS app code in `PanDerm/PanDerm/`

## Next Steps

After successful conversion:

1. **Test the Model**: Run inference on sample images
2. **Optimize Performance**: Consider model quantization if needed
3. **Update iOS App**: Ensure the `LocalInferenceService` works correctly
4. **User Testing**: Test with real dermatology images
5. **Clinical Validation**: Validate performance with medical professionals 
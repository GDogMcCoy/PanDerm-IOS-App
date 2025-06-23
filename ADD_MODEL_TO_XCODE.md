# Adding Core ML Model to Xcode Project

## Step-by-Step Guide

### 1. **Open Xcode Project**
- Open `PanDerm.xcodeproj` in Xcode
- Make sure the project navigator is visible (⌘+1)

### 2. **Add the Model File**
- **Drag and Drop**: Drag `PanDerm-Placeholder-v1.0.mlmodel` from Finder into the `PanDerm/PanDerm/` folder in Xcode's Project Navigator
- **Alternative**: Right-click on the `PanDerm` folder → "Add Files to 'PanDerm'"

### 3. **Configure Model Import**
When the file import dialog appears:
- ✅ **Check "Add to target"**: Make sure "PanDerm" is selected
- ✅ **Check "Copy items if needed"**: This copies the file into your project
- ✅ **Select "Create groups"**: This creates a proper folder structure
- Click **"Add"**

### 4. **Verify Model Addition**
- The model file should appear in your project navigator under `PanDerm/PanDerm/`
- The file should have a blue icon (indicating it's part of the target)
- Xcode will automatically compile the `.mlmodel` to `.mlmodelc` when you build

### 5. **Build the Project**
- Press **⌘+B** to build the project
- Check that there are no errors in the build log
- Xcode should automatically generate Swift code for the model

### 6. **Test the App**
- Press **⌘+R** to run the app
- Navigate to the Image Analysis screen
- Test the image analysis workflow
- Check the console for model loading messages

## Expected Console Output

### If Model is Found:
```
✅ Actual Core ML model loaded successfully
✅ Core ML model loaded from: [path to compiled model]
```

### If Model is Not Found:
```
📝 No Core ML model found in bundle, using simulation
⚠️ Using simulation mode - no Core ML model found
```

## Troubleshooting

### Model Not Found
- **Check file location**: Ensure the model is in the correct folder
- **Check target membership**: Right-click the model file → "Show File Inspector" → Verify target is checked
- **Clean and rebuild**: Product → Clean Build Folder (⌘+Shift+K) then rebuild

### Build Errors
- **Check model format**: Ensure the `.mlmodel` file is valid
- **Check Xcode version**: Core ML requires Xcode 9.0 or later
- **Check iOS deployment target**: Ensure it's iOS 11.0 or later

### Runtime Errors
- **Check console output**: Look for specific error messages
- **Verify model inputs/outputs**: Ensure they match the expected format
- **Test on device**: Some Core ML features work differently on simulator vs device

## Next Steps

After successfully adding the model:
1. **Test the app** and verify the model loads correctly
2. **Test image analysis** functionality
3. **Monitor performance** metrics in the UI
4. **Replace with real model** when available

## Model File Location

The model file should be located at:
```
PanDerm Project/
└── PanDerm/
    └── PanDerm/
        └── PanDerm-Placeholder-v1.0.mlmodel
```

## Model Integration Points

The model is integrated in these files:
- `LocalInferenceService.swift` - Model loading and inference
- `ImageAnalysisView.swift` - UI for model status and results
- `PanDermInferenceManager.swift` - High-level inference management 
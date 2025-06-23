# PanDerm - AI-Powered Skin Analysis App

## Overview

PanDerm is a comprehensive iOS application that leverages advanced AI technology to assist in dermatological analysis. The app provides local on-device inference using Core ML, ensuring privacy and real-time analysis capabilities.

## Features

### 🧠 Core AI Capabilities
- **Local Core ML Inference**: On-device skin condition classification using Apple Neural Engine
- **Real-time Analysis**: Fast image processing with confidence scoring
- **Multi-class Classification**: Support for 9+ skin condition types
- **Performance Monitoring**: Track inference speed and accuracy metrics

### 👥 Patient Management
- **Complete Patient Records**: Store comprehensive patient information
- **Medical History Tracking**: Detailed medical records and analysis history
- **Search and Filter**: Quick patient lookup and filtering
- **Data Export/Import**: Secure patient data management

### 📊 Analysis Features
- **Image Capture**: Camera integration with quality guidelines
- **Analysis History**: Complete timeline of all analyses
- **Confidence Scoring**: Color-coded confidence indicators
- **Detailed Results**: Comprehensive classification breakdown

### ⚙️ Advanced Settings
- **Inference Mode Selection**: Automatic, Local, or Cloud inference
- **Model Management**: Download and update AI models
- **Performance Statistics**: Detailed metrics and insights
- **Data Management**: Clear history and export capabilities

## Architecture

### Core Components

```
PanDerm/
├── Services/
│   └── LocalInferenceService.swift    # Core ML inference engine
├── ViewModels/
│   ├── PatientViewModel.swift         # Patient data management
│   └── SkinConditionViewModel.swift   # Analysis workflow
├── Views/
│   ├── ImageAnalysisView.swift        # Main analysis interface
│   ├── PatientListView.swift          # Patient management
│   ├── AnalysisHistoryView.swift      # History tracking
│   └── InferenceSettingsView.swift    # Settings and configuration
└── Models/
    ├── Patient.swift                  # Patient data models
    ├── SkinCondition.swift           # Medical condition models
    └── AnalysisModels.swift          # ML result models
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Core ML**: On-device machine learning
- **Vision Framework**: Image processing and analysis
- **Metal Performance Shaders**: GPU acceleration
- **UserDefaults**: Local data persistence

## Model Integration

### Core ML Models
The app supports multiple Core ML models:
- `PanDerm.mlpackage`: Primary classification model
- `PanDerm 2.mlpackage`: Enhanced multi-task model

### Supported Classifications
1. Actinic Keratosis
2. Basal Cell Carcinoma
3. Dermatofibroma
4. Melanoma
5. Nevus
6. Pigmented Benign Keratosis
7. Seborrheic Keratosis
8. Squamous Cell Carcinoma
9. Vascular Lesion

## Installation & Setup

### Prerequisites
- iOS 16.0+
- Xcode 15.0+
- Apple Intelligence compatible device (iPhone 15 Pro/Pro Max or newer)

### Setup Steps
1. Clone the repository
2. Open `PanDerm.xcodeproj` in Xcode
3. Add Core ML models to the project bundle
4. Configure signing and capabilities
5. Build and run on device

### Model Setup
1. Ensure `.mlpackage` files are included in the app bundle
2. Verify model loading in `LocalInferenceService`
3. Test inference with sample images

## Usage

### Basic Workflow
1. **Launch App**: Open PanDerm on your device
2. **Add Patient**: Create patient records with medical information
3. **Capture Image**: Take or select skin images for analysis
4. **Run Analysis**: Process images using local AI inference
5. **Review Results**: Examine classification results and confidence scores
6. **Track History**: Monitor patient analysis over time

### Best Practices
- Use good lighting when capturing images
- Keep camera steady and fill frame with skin area
- Include scale reference when possible
- Review confidence scores and seek professional medical advice
- Regularly update models for improved accuracy

## Data Management

### Patient Data
- All patient data stored locally on device
- Export capabilities for data portability
- Secure data handling with encryption
- HIPAA-compliant privacy measures

### Analysis Results
- Complete analysis history per patient
- Detailed classification breakdowns
- Performance metrics tracking
- Export capabilities for research

## Performance

### Optimization Features
- Apple Neural Engine utilization
- Metal GPU acceleration
- Efficient memory management
- Background processing capabilities

### Monitoring
- Real-time inference metrics
- Battery usage optimization
- Network status awareness
- Model performance tracking

## Medical Disclaimer

⚠️ **Important**: This application is for educational and informational purposes only. It should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always consult with a qualified healthcare provider for proper medical care.

## Development

### Code Structure
- **MVVM Architecture**: Clean separation of concerns
- **Environment Objects**: Shared state management
- **Modern SwiftUI**: Latest iOS development practices
- **Error Handling**: Comprehensive error management

### Best Practices
- Consistent coding style and documentation
- Comprehensive error handling and recovery
- Performance optimization and monitoring
- User experience focused design

## Future Enhancements

### Planned Features
- Cloud synchronization capabilities
- Advanced analytics and reporting
- Integration with health records
- Multi-language support
- Telemedicine integration

### Model Improvements
- Expanded classification categories
- Enhanced accuracy and confidence
- Specialized models for different skin types
- Continuous learning capabilities

## Support

For technical support or questions:
- Review documentation and code comments
- Check error messages and logs
- Validate model integration and setup
- Ensure proper device compatibility

## License

This project is for educational and research purposes. Please ensure compliance with all applicable medical device regulations and privacy laws when using in clinical settings.

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Compatibility**: iOS 16.0+, Apple Intelligence iPhones
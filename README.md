# PanDerm - Dermatology iOS App

## Overview
PanDerm is a comprehensive dermatology iOS application designed to assist healthcare professionals in patient management, skin analysis, and treatment planning.

## Project Structure
```
PanDerm/
├── PanDerm/                    # Main app target
│   ├── Models/                 # Data models
│   ├── Views/                  # SwiftUI views
│   ├── ViewModels/             # MVVM view models
│   ├── Services/               # Business logic and API services
│   ├── Utils/                  # Utility classes and helpers
│   ├── Resources/              # Static resources
│   ├── Extensions/             # Swift extensions
│   ├── Protocols/              # Protocol definitions
│   ├── Assets.xcassets/        # App assets
│   ├── Preview Content/        # SwiftUI preview assets
│   ├── PanDermApp.swift        # App entry point
│   ├── ContentView.swift       # Main content view
│   └── Info.plist             # App configuration
├── PanDermTests/              # Unit tests
├── PanDermUITests/            # UI tests
└── Documentation/             # Project documentation
```

## Features
- **Patient Management**: Comprehensive patient records and history
- **Skin Analysis**: AI-powered skin condition analysis
- **Treatment Plans**: Customized treatment recommendations
- **Secure Data**: HIPAA-compliant data handling
- **Offline Support**: Core functionality available offline

## Development Setup

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Swift 5.0+

### Getting Started
1. Clone the repository
2. Open `PanDerm.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run the project

### Development Workflow
- **Cursor**: Use Cursor for code editing and AI assistance
- **Xcode**: Use Xcode for building, testing, and debugging
- **Git**: Regular commits and pushes to maintain backup

## Architecture
- **MVVM Pattern**: Model-View-ViewModel architecture
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Core Data**: Local data persistence
- **HealthKit**: Health data integration (future)

## Testing
- Unit tests in `PanDermTests/`
- UI tests in `PanDermUITests/`
- Run tests with `Cmd+U` in Xcode

## Deployment
- Configure signing and capabilities in Xcode
- Set up App Store Connect for distribution
- Follow Apple's App Store guidelines

## Contributing
1. Create a feature branch
2. Make your changes
3. Add tests for new functionality
4. Submit a pull request

## License
[Add your license information here]

## Support
For support and questions, please contact the development team. 
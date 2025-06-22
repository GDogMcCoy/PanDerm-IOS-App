# Services

This directory contains business logic and API services for the PanDerm application.

## Structure
- **NetworkService.swift** - HTTP networking layer
- **DataService.swift** - Core Data operations
- **AuthService.swift** - Authentication and authorization
- **ImageAnalysisService.swift** - AI skin analysis
- **NotificationService.swift** - Push notifications
- **HealthKitService.swift** - Health data integration

## Guidelines
- Use protocol-oriented programming
- Implement proper error handling
- Use async/await for modern concurrency
- Add comprehensive logging
- Implement retry logic for network calls
- Use dependency injection
- Add unit tests for all services 
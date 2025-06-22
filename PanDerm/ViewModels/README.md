# ViewModels

This directory contains MVVM view models for the PanDerm application.

## Structure
- **PatientViewModel.swift** - Patient management logic
- **AnalysisViewModel.swift** - Skin analysis logic
- **TreatmentViewModel.swift** - Treatment plan logic
- **AppointmentViewModel.swift** - Appointment scheduling logic

## Guidelines
- Inherit from `ObservableObject`
- Use `@Published` for reactive properties
- Implement proper error handling
- Use dependency injection for services
- Keep business logic separate from UI
- Add unit tests for all view models
- Use Combine for async operations 
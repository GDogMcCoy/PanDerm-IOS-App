# Models

This directory contains the data models for the PanDerm application.

## Structure
- **Patient.swift** - Patient data model
- **SkinCondition.swift** - Skin condition classification
- **Treatment.swift** - Treatment plan model
- **Appointment.swift** - Appointment scheduling model
- **MedicalRecord.swift** - Medical history and records

## Guidelines
- Use `Codable` for JSON serialization
- Implement `Identifiable` for SwiftUI lists
- Use `@Published` properties for reactive updates
- Follow Swift naming conventions
- Add documentation comments for public interfaces 
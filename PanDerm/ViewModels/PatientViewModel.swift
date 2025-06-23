import Foundation
import SwiftUI

/// ViewModel for managing patient data
@MainActor
class PatientViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var selectedPatient: Patient?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    // The dependency on PanDermInferenceManager has been removed.
    // This ViewModel is now only responsible for patient data management.
    // Inference and analysis are handled by LocalInferenceService and SkinConditionViewModel.
    
    // MARK: - Computed Properties
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        } else {
            return patients.filter { patient in
                patient.fullName.localizedCaseInsensitiveContains(searchText) ||
                patient.contactInfo.email?.localizedCaseInsensitiveContains(searchText) == true ||
                patient.contactInfo.phone?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    // These computed properties remain as they are based on patient data, not inference.
    var highRiskPatients: [Patient] {
        // This logic would be updated based on a more robust risk model
        return patients.filter { $0.riskFactors.riskScore > 7 }
    }
    
    var patientsNeedingFollowUp: [Patient] {
        // This would be implemented with real appointment data
        return []
    }
    
    // MARK: - Patient Management
    
    func addPatient(_ patient: Patient) {
        patients.append(patient)
        savePatients()
    }
    
    func updatePatient(_ patient: Patient) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index] = patient
            savePatients()
        }
    }
    
    func deletePatient(_ patient: Patient) {
        patients.removeAll { $0.id == patient.id }
        savePatients()
    }
    
    func selectPatient(_ patient: Patient) {
        selectedPatient = patient
    }
    
    // MARK: - Risk Assessment (Simplified)
    
    func getRiskLevel(for patient: Patient) -> String {
        // Simplified risk level calculation
        switch patient.riskFactors.riskScore {
        case 0...3:
            return "Low"
        case 4...6:
            return "Medium"
        case 7...10:
            return "High"
        default:
            return "Unknown"
        }
    }
    
    func getRiskRecommendations(for patient: Patient) -> [String] {
        var recommendations: [String] = []
        
        if patient.riskFactors.fairSkin {
            recommendations.append("Use broad-spectrum sunscreen with SPF 30+ daily.")
        }
        if patient.riskFactors.manyMoles {
            recommendations.append("Schedule regular skin cancer screenings.")
        }
        if patient.riskFactors.severeSunburns {
            recommendations.append("Avoid peak sun hours (10 AM - 4 PM).")
        }
        if patient.riskFactors.familyHistory || patient.riskFactors.personalHistory {
            recommendations.append("Inform your dermatologist of your history.")
        }
        
        return recommendations
    }
    
    // All methods and properties related to PanDermInferenceManager have been removed.
    // This includes `analyzePatientRisk`, `generatePatientReport`, `inferenceStatus`, etc.
    // as they were tied to the old, complex architecture.
    
    private func getRiskFactors(for patient: Patient) -> [String] {
        var factors: [String] = []
        
        if patient.riskFactors.fairSkin { factors.append("Fair skin") }
        if patient.riskFactors.lightHair { factors.append("Light hair") }
        if patient.riskFactors.lightEyes { factors.append("Light eyes") }
        if patient.riskFactors.freckles { factors.append("Freckles") }
        if patient.riskFactors.manyMoles { factors.append("Many moles") }
        if patient.riskFactors.atypicalMoles { factors.append("Atypical moles") }
        if patient.riskFactors.severeSunburns { factors.append("History of severe sunburns") }
        if patient.riskFactors.familyHistory { factors.append("Family history of skin cancer") }
        if patient.riskFactors.personalHistory { factors.append("Personal history of skin cancer") }
        if patient.riskFactors.immunosuppression { factors.append("Immunosuppression") }
        if patient.riskFactors.xerodermaPigmentosum { factors.append("Xeroderma pigmentosum") }
        
        return factors
    }
    
    // MARK: - Data Persistence
    
    private func savePatients() {
        // This would integrate with Core Data or other persistence layer.
        // For now, we'll use UserDefaults as a simple storage solution.
        if let encoded = try? JSONEncoder().encode(patients) {
            UserDefaults.standard.set(encoded, forKey: "savedPatients")
        }
    }
    
    func loadPatients() {
        if let data = UserDefaults.standard.data(forKey: "savedPatients"),
           let decoded = try? JSONDecoder().decode([Patient].self, from: data) {
            patients = decoded
        } else {
            // Load sample data if no saved data is found
            patients = Patient.sampleData
        }
    }
    
    func loadSampleData() {
        patients = Patient.sampleData
        savePatients()
    }
    
    func analyzePatientRisk() async {
        // Placeholder for patient risk analysis
        // This would integrate with the LocalInferenceService for actual analysis
        isLoading = true
        
        // Simulate analysis delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        isLoading = false
    }
}

// MARK: - Supporting Types

struct PatientReport {
    let patient: Patient
    let riskAssessment: RiskAssessment?
    let recommendations: [String]
}

struct RiskAssessment {
    let score: Int
    let level: String
    let factors: [String]
    let lastUpdated: Date
} 
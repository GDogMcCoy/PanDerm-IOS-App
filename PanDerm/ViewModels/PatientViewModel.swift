import Foundation
import SwiftUI
import Combine

/// ViewModel for managing patient data
@MainActor
class PatientViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var selectedPatient: Patient?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let dataService = PatientDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchDebouncing()
    }
    
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
    
    func loadPatients() async {
        isLoading = true
        errorMessage = nil
        
        do {
            patients = try await dataService.fetchPatients()
            isLoading = false
        } catch {
            errorMessage = "Failed to load patients: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func refreshPatients() async {
        await loadPatients()
    }
    
    func addPatient(_ patient: Patient) {
        patients.append(patient)
        
        Task {
            do {
                try await dataService.savePatient(patient)
            } catch {
                // Remove from local array if save fails
                if let index = patients.firstIndex(where: { $0.id == patient.id }) {
                    patients.remove(at: index)
                }
                errorMessage = "Failed to save patient: \(error.localizedDescription)"
            }
        }
    }
    
    func updatePatient(_ patient: Patient) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            var updatedPatient = patient
            updatedPatient = Patient(
                id: patient.id,
                firstName: patient.firstName,
                lastName: patient.lastName,
                dateOfBirth: patient.dateOfBirth,
                gender: patient.gender,
                ethnicity: patient.ethnicity,
                skinType: patient.skinType,
                contactInfo: patient.contactInfo,
                medicalHistory: patient.medicalHistory,
                riskFactors: patient.riskFactors,
                createdAt: patient.createdAt,
                updatedAt: Date()
            )
            patients[index] = updatedPatient
            
            Task {
                do {
                    try await dataService.updatePatient(updatedPatient)
                } catch {
                    errorMessage = "Failed to update patient: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deletePatient(_ patient: Patient) {
        patients.removeAll { $0.id == patient.id }
        
        Task {
            do {
                try await dataService.deletePatient(patient.id)
            } catch {
                // Re-add if deletion fails
                patients.append(patient)
                errorMessage = "Failed to delete patient: \(error.localizedDescription)"
            }
        }
    }
    
    func getPatient(by id: UUID) -> Patient? {
        return patients.first { $0.id == id }
    }
    
    // MARK: - Search and Filtering
    
    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ searchText: String) {
        // Search functionality is now handled in the view itself
        // This method can be used for more complex search operations
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        #if DEBUG
        patients = Patient.sampleData
        #endif
    }
    
    // MARK: - Statistics
    
    var totalPatients: Int {
        patients.count
    }
    
    var highRiskPatients: Int {
        patients.filter { $0.riskFactors.riskLevel == "High" || $0.riskFactors.riskLevel == "Very High" }.count
    }
    
    var averageAge: Double {
        guard !patients.isEmpty else { return 0 }
        let totalAge = patients.reduce(0) { $0 + $1.age }
        return Double(totalAge) / Double(patients.count)
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

// MARK: - Patient Data Service

class PatientDataService {
    private let storageKey = "panderm_patients"
    
    func fetchPatients() async throws -> [Patient] {
        // For now, use UserDefaults. In production, this would be Core Data or CloudKit
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let patients = try? JSONDecoder().decode([Patient].self, from: data) else {
            return []
        }
        return patients
    }
    
    func savePatient(_ patient: Patient) async throws {
        var patients = try await fetchPatients()
        patients.append(patient)
        try await savePatients(patients)
    }
    
    func updatePatient(_ patient: Patient) async throws {
        var patients = try await fetchPatients()
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index] = patient
            try await savePatients(patients)
        }
    }
    
    func deletePatient(_ patientId: UUID) async throws {
        var patients = try await fetchPatients()
        patients.removeAll { $0.id == patientId }
        try await savePatients(patients)
    }
    
    private func savePatients(_ patients: [Patient]) async throws {
        let data = try JSONEncoder().encode(patients)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
} 
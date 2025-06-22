import Foundation
import SwiftUI

/// ViewModel for managing patient data and PanDerm analysis
/// Handles patient CRUD operations, risk assessment, and AI integration with local inference
@MainActor
class PatientViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var selectedPatient: Patient?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    // Inference manager for local/cloud analysis
    @StateObject private var inferenceManager = PanDermInferenceManager()
    
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
    
    var highRiskPatients: [Patient] {
        patients.filter { $0.riskFactors.riskLevel == "High" || $0.riskFactors.riskLevel == "Very High" }
    }
    
    var patientsNeedingFollowUp: [Patient] {
        // This would be implemented with appointment data
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
    
    // MARK: - Risk Assessment
    
    func calculateRiskScore(for patient: Patient) -> Int {
        return patient.riskFactors.riskScore
    }
    
    func getRiskLevel(for patient: Patient) -> String {
        return patient.riskFactors.riskLevel
    }
    
    func getRiskRecommendations(for patient: Patient) -> [String] {
        var recommendations: [String] = []
        
        if patient.riskFactors.fairSkin {
            recommendations.append("Use broad-spectrum sunscreen with SPF 30+ daily")
        }
        if patient.riskFactors.manyMoles {
            recommendations.append("Schedule regular skin cancer screenings")
        }
        if patient.riskFactors.severeSunburns {
            recommendations.append("Avoid peak sun hours (10 AM - 4 PM)")
        }
        if patient.riskFactors.familyHistory {
            recommendations.append("Consider genetic counseling")
        }
        
        return recommendations
    }
    
    // MARK: - PanDerm Integration with Local Inference
    
    func analyzePatientRisk() async {
        guard let patient = selectedPatient else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let analysisResult = try await inferenceManager.analyzePatientRisk(patient)
            
            // Update patient with analysis results
            var updatedPatient = patient
            
            // Update risk factors with AI analysis results
            updatedPatient.riskFactors.riskScore = analysisResult.riskScore
            updatedPatient.riskFactors.riskLevel = analysisResult.riskLevel
            
            // Add analysis metadata
            // Note: In a full implementation, you'd store the analysis result in the patient's medical record
            
            updatePatient(updatedPatient)
            
        } catch {
            errorMessage = "Failed to analyze patient risk: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func generatePatientReport() -> PatientReport {
        guard let patient = selectedPatient else {
            return PatientReport(patient: Patient(id: UUID(), firstName: "", lastName: "", dateOfBirth: Date(), gender: .male, contactInfo: ContactInfo()), riskAssessment: nil, recommendations: [])
        }
        
        let riskScore = calculateRiskScore(for: patient)
        let riskLevel = getRiskLevel(for: patient)
        let recommendations = getRiskRecommendations(for: patient)
        
        let riskAssessment = RiskAssessment(
            score: riskScore,
            level: riskLevel,
            factors: getRiskFactors(for: patient),
            lastUpdated: Date()
        )
        
        return PatientReport(
            patient: patient,
            riskAssessment: riskAssessment,
            recommendations: recommendations
        )
    }
    
    // MARK: - Batch Risk Analysis
    
    func analyzeAllPatientsRisk() async {
        guard !patients.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        var updatedPatients: [Patient] = []
        
        for patient in patients {
            do {
                let analysisResult = try await inferenceManager.analyzePatientRisk(patient)
                
                var updatedPatient = patient
                updatedPatient.riskFactors.riskScore = analysisResult.riskScore
                updatedPatient.riskFactors.riskLevel = analysisResult.riskLevel
                
                updatedPatients.append(updatedPatient)
                
            } catch {
                errorMessage = "Failed to analyze risk for \(patient.fullName): \(error.localizedDescription)"
                updatedPatients.append(patient) // Keep original patient data
            }
        }
        
        patients = updatedPatients
        savePatients()
        isLoading = false
    }
    
    // MARK: - Inference Status and Monitoring
    
    var inferenceStatus: String {
        if inferenceManager.isLoading {
            return "\(inferenceManager.currentOperation) (\(Int(inferenceManager.inferenceProgress * 100))%)"
        } else {
            return "Ready"
        }
    }
    
    var inferenceMode: String {
        return inferenceManager.inferenceMode.rawValue
    }
    
    var isLocalModelAvailable: Bool {
        return inferenceManager.localModelStatus == .loaded
    }
    
    var isOnline: Bool {
        return inferenceManager.isOnline
    }
    
    var currentOperation: String {
        return inferenceManager.currentOperation
    }
    
    var inferenceProgress: Double {
        return inferenceManager.inferenceProgress
    }
    
    // MARK: - Performance Monitoring
    
    func getPerformanceStats() -> PerformanceStats {
        return inferenceManager.getPerformanceStats()
    }
    
    func clearPerformanceData() {
        inferenceManager.clearPerformanceData()
    }
    
    // MARK: - Model Management
    
    func downloadModel() async {
        do {
            try await inferenceManager.downloadModel()
        } catch {
            errorMessage = "Failed to download model: \(error.localizedDescription)"
        }
    }
    
    func updateModel() async {
        do {
            try await inferenceManager.updateLocalModel()
        } catch {
            errorMessage = "Failed to update model: \(error.localizedDescription)"
        }
    }
    
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
        // This would integrate with Core Data or other persistence layer
        // For now, we'll use UserDefaults as a simple storage solution
        if let encoded = try? JSONEncoder().encode(patients) {
            UserDefaults.standard.set(encoded, forKey: "savedPatients")
        }
    }
    
    func loadPatients() {
        if let data = UserDefaults.standard.data(forKey: "savedPatients"),
           let decoded = try? JSONDecoder().decode([Patient].self, from: data) {
            patients = decoded
        }
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        let samplePatients = [
            Patient(
                firstName: "John",
                lastName: "Smith",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date()) ?? Date(),
                gender: .male,
                ethnicity: .white,
                skinType: .type2,
                contactInfo: ContactInfo(
                    email: "john.smith@email.com",
                    phone: "555-0123"
                ),
                medicalHistory: MedicalHistory(
                    familyHistory: FamilyHistory(melanoma: true)
                ),
                riskFactors: RiskFactors(
                    fairSkin: true,
                    lightHair: true,
                    lightEyes: true,
                    freckles: true,
                    manyMoles: true,
                    severeSunburns: true,
                    familyHistory: true
                )
            ),
            Patient(
                firstName: "Sarah",
                lastName: "Johnson",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -32, to: Date()) ?? Date(),
                gender: .female,
                ethnicity: .white,
                skinType: .type1,
                contactInfo: ContactInfo(
                    email: "sarah.johnson@email.com",
                    phone: "555-0456"
                ),
                riskFactors: RiskFactors(
                    fairSkin: true,
                    lightHair: true,
                    lightEyes: true,
                    freckles: true,
                    severeSunburns: true
                )
            )
        ]
        
        patients = samplePatients
        savePatients()
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
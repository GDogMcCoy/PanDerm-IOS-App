import Foundation
import SwiftUI

/// ViewModel for managing patient data and operations
@MainActor
class PatientViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var patients: [Patient] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPatient: Patient?
    
    // MARK: - Initialization
    
    init() {
        loadPatients()
    }
    
    // MARK: - Patient Management
    
    func loadPatients() {
        isLoading = true
        
        // Load from UserDefaults or Core Data
        // For now, load sample data in debug mode
        #if DEBUG
        if patients.isEmpty {
            patients = Patient.sampleData
        }
        #endif
        
        isLoading = false
    }
    
    func addPatient(_ patient: Patient) {
        patients.append(patient)
        savePatients()
    }
    
    func updatePatient(_ patient: Patient) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            var updatedPatient = patient
            updatedPatient.updatedAt = Date()
            patients[index] = updatedPatient
            savePatients()
        }
    }
    
    func deletePatient(_ patient: Patient) {
        patients.removeAll { $0.id == patient.id }
        savePatients()
    }
    
    func getPatient(by id: UUID) -> Patient? {
        return patients.first { $0.id == id }
    }
    
    // MARK: - Medical Records Management
    
    func addMedicalRecord(_ medicalRecord: MedicalRecord, to patient: Patient) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index].medicalRecords.append(medicalRecord)
            patients[index].updatedAt = Date()
            savePatients()
        }
    }
    
    func updateMedicalRecord(_ medicalRecord: MedicalRecord, for patient: Patient) {
        if let patientIndex = patients.firstIndex(where: { $0.id == patient.id }),
           let recordIndex = patients[patientIndex].medicalRecords.firstIndex(where: { $0.id == medicalRecord.id }) {
            patients[patientIndex].medicalRecords[recordIndex] = medicalRecord
            patients[patientIndex].updatedAt = Date()
            savePatients()
        }
    }
    
    func deleteMedicalRecord(_ medicalRecord: MedicalRecord, from patient: Patient) {
        if let patientIndex = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[patientIndex].medicalRecords.removeAll { $0.id == medicalRecord.id }
            patients[patientIndex].updatedAt = Date()
            savePatients()
        }
    }
    
    // MARK: - Analysis Results Management
    
    func addAnalysisResult(_ analysisSession: AnalysisSession, to medicalRecord: MedicalRecord, for patient: Patient) {
        if let patientIndex = patients.firstIndex(where: { $0.id == patient.id }),
           let recordIndex = patients[patientIndex].medicalRecords.firstIndex(where: { $0.id == medicalRecord.id }) {
            patients[patientIndex].medicalRecords[recordIndex].analysisResults.append(analysisSession)
            patients[patientIndex].updatedAt = Date()
            savePatients()
        }
    }
    
    // MARK: - Data Persistence
    
    private func savePatients() {
        do {
            let data = try JSONEncoder().encode(patients)
            UserDefaults.standard.set(data, forKey: "SavedPatients")
        } catch {
            errorMessage = "Failed to save patients: \(error.localizedDescription)"
        }
    }
    
    private func loadPatientsFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: "SavedPatients") else {
            return
        }
        
        do {
            patients = try JSONDecoder().decode([Patient].self, from: data)
        } catch {
            errorMessage = "Failed to load patients: \(error.localizedDescription)"
            // Fall back to sample data in debug mode
            #if DEBUG
            patients = Patient.sampleData
            #endif
        }
    }
    
    // MARK: - Search and Filter
    
    func searchPatients(query: String) -> [Patient] {
        if query.isEmpty {
            return patients
        }
        
        return patients.filter { patient in
            patient.firstName.localizedCaseInsensitiveContains(query) ||
            patient.lastName.localizedCaseInsensitiveContains(query) ||
            patient.medicalRecordNumber.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getRecentPatients(limit: Int = 5) -> [Patient] {
        return patients
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit)
            .map { $0 }
    }
    
    func getPatientsWithRecentAnalysis() -> [Patient] {
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        return patients.filter { patient in
            patient.medicalRecords.contains { record in
                record.analysisResults.contains { analysis in
                    analysis.timestamp >= oneWeekAgo
                }
            }
        }
    }
    
    // MARK: - Statistics
    
    func getTotalAnalysisCount() -> Int {
        return patients.reduce(0) { total, patient in
            total + patient.analysisCount
        }
    }
    
    func getAverageAge() -> Double {
        guard !patients.isEmpty else { return 0 }
        let totalAge = patients.reduce(0) { $0 + $1.age }
        return Double(totalAge) / Double(patients.count)
    }
    
    func getAnalysisCountForPatient(_ patient: Patient) -> Int {
        return patient.analysisCount
    }
    
    // MARK: - Export and Import
    
    func exportPatientData(_ patient: Patient) -> Data? {
        do {
            return try JSONEncoder().encode(patient)
        } catch {
            errorMessage = "Failed to export patient data: \(error.localizedDescription)"
            return nil
        }
    }
    
    func exportAllPatientsData() -> Data? {
        do {
            return try JSONEncoder().encode(patients)
        } catch {
            errorMessage = "Failed to export all patients data: \(error.localizedDescription)"
            return nil
        }
    }
    
    func importPatientData(_ data: Data) -> Bool {
        do {
            let importedPatient = try JSONDecoder().decode(Patient.self, from: data)
            
            // Check if patient already exists
            if !patients.contains(where: { $0.id == importedPatient.id }) {
                addPatient(importedPatient)
                return true
            } else {
                errorMessage = "Patient already exists"
                return false
            }
        } catch {
            errorMessage = "Failed to import patient data: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Validation
    
    func validatePatient(_ patient: Patient) -> [String] {
        var errors: [String] = []
        
        if patient.firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("First name is required")
        }
        
        if patient.lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Last name is required")
        }
        
        if patient.medicalRecordNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Medical record number is required")
        }
        
        // Check for duplicate medical record number
        if patients.contains(where: { $0.medicalRecordNumber == patient.medicalRecordNumber && $0.id != patient.id }) {
            errors.append("Medical record number already exists")
        }
        
        // Validate age (must be reasonable)
        if patient.age < 0 || patient.age > 150 {
            errors.append("Invalid date of birth")
        }
        
        return errors
    }
    
    func isValidPatient(_ patient: Patient) -> Bool {
        return validatePatient(patient).isEmpty
    }
    
    // MARK: - Helper Methods
    
    func clearAllData() {
        patients.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedPatients")
    }
    
    func refreshData() {
        loadPatientsFromStorage()
    }
    
    func getPatientAnalysisHistory(_ patient: Patient) -> [AnalysisSession] {
        return patient.medicalRecords.flatMap { $0.analysisResults }
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
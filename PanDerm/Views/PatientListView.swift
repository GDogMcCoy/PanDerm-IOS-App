import SwiftUI

/// Main view for displaying and managing the list of patients
/// Features search, filtering, and navigation to patient details
struct PatientListView: View {
    @StateObject private var patientViewModel = PatientViewModel()
    @EnvironmentObject private var inferenceManager: PanDermInferenceManager
    
    @State private var showingAddPatient = false
    @State private var selectedPatient: Patient?
    @State private var showingPatientDetail = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if patientViewModel.patients.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredPatients) { patient in
                            PatientRow(patient: patient)
                                .onTapGesture {
                                    selectedPatient = patient
                                    showingPatientDetail = true
                                }
                        }
                        .onDelete(perform: deletePatients)
                    }
                    .searchable(text: $searchText, prompt: "Search patients...")
                }
            }
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPatient = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                if !patientViewModel.patients.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddPatient) {
                AddPatientView()
                    .environmentObject(patientViewModel)
            }
            .sheet(isPresented: $showingPatientDetail) {
                if let patient = selectedPatient {
                    PatientDetailView(patient: patient)
                        .environmentObject(patientViewModel)
                        .environmentObject(inferenceManager)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Patients")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add your first patient to start tracking skin analysis history")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAddPatient = true
            }) {
                Label("Add Patient", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patientViewModel.patients
        } else {
            return patientViewModel.patients.filter { patient in
                patient.firstName.localizedCaseInsensitiveContains(searchText) ||
                patient.lastName.localizedCaseInsensitiveContains(searchText) ||
                patient.medicalRecordNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func deletePatients(at offsets: IndexSet) {
        let patientsToDelete = offsets.map { filteredPatients[$0] }
        for patient in patientsToDelete {
            patientViewModel.deletePatient(patient)
        }
    }
}

struct PatientRow: View {
    let patient: Patient
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(patient.initials)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text("\(patient.firstName) \(patient.lastName)")
                    .font(.headline)
                
                // Details
                HStack {
                    Text("Age \(patient.age)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(patient.medicalRecordNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recent activity
                if let lastVisit = patient.medicalRecords.last {
                    Text("Last visit: \(lastVisit.date, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Analysis count
                Text("\(patient.analysisCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("analyses")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddPatientView: View {
    @EnvironmentObject private var patientViewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var medicalRecordNumber = ""
    @State private var emergencyContact = ""
    @State private var allergies = ""
    @State private var currentMedications = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    TextField("Medical Record Number", text: $medicalRecordNumber)
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Emergency Contact", text: $emergencyContact)
                }
                
                Section(header: Text("Medical History")) {
                    TextField("Known Allergies", text: $allergies, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Current Medications", text: $currentMedications, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Additional Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePatient()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !medicalRecordNumber.isEmpty
    }
    
    private func savePatient() {
        let newPatient = Patient(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            medicalRecordNumber: medicalRecordNumber,
            emergencyContact: emergencyContact.isEmpty ? nil : emergencyContact,
            allergies: allergies.isEmpty ? nil : allergies,
            currentMedications: currentMedications.isEmpty ? nil : currentMedications,
            notes: notes.isEmpty ? nil : notes
        )
        
        patientViewModel.addPatient(newPatient)
        dismiss()
    }
}

#Preview {
    PatientListView()
        .environmentObject(PanDermInferenceManager())
} 
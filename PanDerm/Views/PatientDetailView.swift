import SwiftUI

/// Detailed view for displaying comprehensive patient information
/// Shows demographics, risk factors, medical history, and PanDerm analysis
struct PatientDetailView: View {
    let patient: Patient
    @EnvironmentObject private var patientViewModel: PatientViewModel
    @EnvironmentObject private var inferenceManager: PanDermInferenceManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditPatient = false
    @State private var showingNewAnalysis = false
    @State private var showingAnalysisDetail = false
    @State private var selectedAnalysis: AnalysisSession?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Patient Header
                    patientHeaderSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Recent Analysis
                    if !analysisHistory.isEmpty {
                        recentAnalysisSection
                    }
                    
                    // Medical Information
                    medicalInformationSection
                    
                    // Analysis History
                    analysisHistorySection
                }
                .padding()
            }
            .navigationTitle("\(patient.firstName) \(patient.lastName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditPatient = true }) {
                            Label("Edit Patient", systemImage: "pencil")
                        }
                        
                        Button(action: { showingNewAnalysis = true }) {
                            Label("New Analysis", systemImage: "camera.fill")
                        }
                        
                        Button(action: { exportPatientData() }) {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditPatient) {
            EditPatientView(patient: patient)
                .environmentObject(patientViewModel)
        }
        .sheet(isPresented: $showingNewAnalysis) {
            ImageAnalysisView()
                .environmentObject(inferenceManager)
        }
        .sheet(isPresented: $showingAnalysisDetail) {
            if let analysis = selectedAnalysis {
                AnalysisSessionDetailView(session: analysis)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var analysisHistory: [AnalysisSession] {
        patientViewModel.getPatientAnalysisHistory(patient)
    }
    
    private var recentAnalyses: [AnalysisSession] {
        analysisHistory
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - View Sections
    
    private var patientHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text(patient.initials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(patient.firstName) \(patient.lastName)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Age \(patient.age)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("MRN: \(patient.medicalRecordNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Patient since \(patient.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Analyses",
                value: "\(patient.analysisCount)",
                icon: "brain.head.profile",
                color: .blue
            )
            
            StatCard(
                title: "Medical Records",
                value: "\(patient.medicalRecords.count)",
                icon: "doc.text",
                color: .green
            )
            
            if let lastAnalysis = analysisHistory.last {
                StatCard(
                    title: "Last Analysis",
                    value: timeAgoString(from: lastAnalysis.timestamp),
                    icon: "clock",
                    color: .orange
                )
            }
        }
    }
    
    private var recentAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Analysis")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    // Show all analyses
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            ForEach(recentAnalyses) { analysis in
                RecentAnalysisRow(analysis: analysis) {
                    selectedAnalysis = analysis
                    showingAnalysisDetail = true
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var medicalInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medical Information")
                .font(.headline)
            
            if let emergencyContact = patient.emergencyContact {
                InfoRow(title: "Emergency Contact", value: emergencyContact)
            }
            
            if let allergies = patient.allergies {
                InfoRow(title: "Allergies", value: allergies)
            }
            
            if let medications = patient.currentMedications {
                InfoRow(title: "Current Medications", value: medications)
            }
            
            if let notes = patient.notes {
                InfoRow(title: "Notes", value: notes)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var analysisHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Analysis History")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingNewAnalysis = true }) {
                    Label("New Analysis", systemImage: "plus")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if analysisHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No analysis history")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Start analyzing skin images to build a comprehensive medical history")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(analysisHistory.sorted(by: { $0.timestamp > $1.timestamp })) { analysis in
                    AnalysisHistoryRow(session: analysis)
                        .onTapGesture {
                            selectedAnalysis = analysis
                            showingAnalysisDetail = true
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func exportPatientData() {
        if let data = patientViewModel.exportPatientData(patient) {
            // Show share sheet or save to files
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(patient.fullName)_data.json")
            
            do {
                try data.write(to: tempURL)
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(activityVC, animated: true)
                }
            } catch {
                // Handle error
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct RecentAnalysisRow: View {
    let analysis: AnalysisSession
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Thumbnail
                if let image = UIImage(data: analysis.image.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if let topResult = analysis.result.classifications.first {
                        Text(topResult.label.capitalized.replacingOccurrences(of: "_", with: " "))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("\(Int(topResult.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(analysis.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnalysisHistoryRow: View {
    let session: AnalysisSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Analysis thumbnail
            if let image = UIImage(data: session.image.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Top classification
                if let topResult = session.result.classifications.first {
                    Text(topResult.label.capitalized.replacingOccurrences(of: "_", with: " "))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ProgressView(value: topResult.confidence)
                        .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor(topResult.confidence)))
                        .frame(height: 4)
                }
                
                HStack {
                    Text(session.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(session.inferenceMode.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .orange
        default:
            return .red
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
}

struct EditPatientView: View {
    let patient: Patient
    @EnvironmentObject private var patientViewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var dateOfBirth: Date
    @State private var medicalRecordNumber: String
    @State private var emergencyContact: String
    @State private var allergies: String
    @State private var currentMedications: String
    @State private var notes: String
    
    init(patient: Patient) {
        self.patient = patient
        _firstName = State(initialValue: patient.firstName)
        _lastName = State(initialValue: patient.lastName)
        _dateOfBirth = State(initialValue: patient.dateOfBirth)
        _medicalRecordNumber = State(initialValue: patient.medicalRecordNumber)
        _emergencyContact = State(initialValue: patient.emergencyContact ?? "")
        _allergies = State(initialValue: patient.allergies ?? "")
        _currentMedications = State(initialValue: patient.currentMedications ?? "")
        _notes = State(initialValue: patient.notes ?? "")
    }
    
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
            .navigationTitle("Edit Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedPatient = patient
        updatedPatient.firstName = firstName
        updatedPatient.lastName = lastName
        updatedPatient.dateOfBirth = dateOfBirth
        updatedPatient.medicalRecordNumber = medicalRecordNumber
        updatedPatient.emergencyContact = emergencyContact.isEmpty ? nil : emergencyContact
        updatedPatient.allergies = allergies.isEmpty ? nil : allergies
        updatedPatient.currentMedications = currentMedications.isEmpty ? nil : currentMedications
        updatedPatient.notes = notes.isEmpty ? nil : notes
        
        patientViewModel.updatePatient(updatedPatient)
        dismiss()
    }
}

#Preview {
    PatientDetailView(patient: Patient.sampleData[0])
        .environmentObject(PatientViewModel())
        .environmentObject(PanDermInferenceManager())
} 
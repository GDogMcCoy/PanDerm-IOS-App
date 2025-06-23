import SwiftUI

/// Detailed view for displaying comprehensive patient information
/// Shows demographics, risk factors, medical history, and PanDerm analysis
struct PatientDetailView: View {
    let patient: Patient
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var showingAnalysisHistory = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Patient Header
                    patientHeaderView
                    
                    // Basic Information
                    basicInformationSection
                    
                    // Risk Assessment
                    riskAssessmentSection
                    
                    // Contact Information
                    contactInformationSection
                    
                    // Medical History
                    medicalHistorySection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Patient Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditPatientView(patient: patient)
            }
            .sheet(isPresented: $showingAnalysisHistory) {
                PatientAnalysisHistoryView(patient: patient)
            }
        }
    }
    
    // MARK: - Patient Header
    
    private var patientHeaderView: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(avatarGradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(patient.initials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text(patient.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(patient.age) years old • \(patient.gender.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let skinType = patient.skinType {
                    Text(skinType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Basic Information
    
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Basic Information")
            
            VStack(spacing: 8) {
                InfoRow(title: "Date of Birth", value: patient.dateOfBirth.formatted(date: .long, time: .omitted))
                InfoRow(title: "Age", value: "\(patient.age) years")
                InfoRow(title: "Gender", value: patient.gender.displayName)
                
                if let ethnicity = patient.ethnicity {
                    InfoRow(title: "Ethnicity", value: ethnicity.displayName)
                }
                
                if let skinType = patient.skinType {
                    InfoRow(title: "Skin Type", value: skinType.displayName)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
    }
    
    // MARK: - Risk Assessment
    
    private var riskAssessmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Risk Assessment")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Overall Risk Level")
                        .font(.headline)
                    
                    Spacer()
                    
                    RiskBadge(level: patient.riskFactors.riskLevel)
                }
                
                HStack {
                    Text("Risk Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(patient.riskFactors.riskScore)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risk Factors")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        RiskFactorChip(title: "Fair Skin", active: patient.riskFactors.fairSkin)
                        RiskFactorChip(title: "Light Hair", active: patient.riskFactors.lightHair)
                        RiskFactorChip(title: "Light Eyes", active: patient.riskFactors.lightEyes)
                        RiskFactorChip(title: "Freckles", active: patient.riskFactors.freckles)
                        RiskFactorChip(title: "Many Moles", active: patient.riskFactors.manyMoles)
                        RiskFactorChip(title: "Atypical Moles", active: patient.riskFactors.atypicalMoles)
                        RiskFactorChip(title: "Severe Sunburns", active: patient.riskFactors.severeSunburns)
                        RiskFactorChip(title: "Family History", active: patient.riskFactors.familyHistory)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
    }
    
    // MARK: - Contact Information
    
    private var contactInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Contact Information")
            
            VStack(spacing: 8) {
                if let email = patient.contactInfo.email {
                    InfoRow(title: "Email", value: email)
                }
                
                if let phone = patient.contactInfo.phone {
                    InfoRow(title: "Phone", value: phone)
                }
                
                if patient.contactInfo.email == nil && patient.contactInfo.phone == nil {
                    Text("No contact information available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
    }
    
    // MARK: - Medical History
    
    private var medicalHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Medical History")
            
            VStack(spacing: 12) {
                if !patient.medicalHistory.medications.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Medications")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(patient.medicalHistory.medications.filter { $0.isActive }.prefix(3), id: \.id) { medication in
                            HStack {
                                Text(medication.name)
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text(medication.dosage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if !patient.medicalHistory.allergies.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Allergies")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(patient.medicalHistory.allergies.prefix(3), id: \.id) { allergy in
                            HStack {
                                Text(allergy.allergen)
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text(allergy.severity.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(severityColor(allergy.severity))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                if patient.medicalHistory.medications.isEmpty && patient.medicalHistory.allergies.isEmpty {
                    Text("No medical history recorded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Actions")
            
            VStack(spacing: 12) {
                ActionButton(
                    title: "Start New Analysis",
                    subtitle: "Capture and analyze skin images",
                    icon: "camera.fill",
                    color: .blue
                ) {
                    // Navigate to analysis view
                }
                
                ActionButton(
                    title: "View Analysis History",
                    subtitle: "Review past analyses for this patient",
                    icon: "clock.fill",
                    color: .green
                ) {
                    showingAnalysisHistory = true
                }
                
                ActionButton(
                    title: "Schedule Appointment",
                    subtitle: "Book follow-up consultation",
                    icon: "calendar.badge.plus",
                    color: .orange
                ) {
                    // Navigate to appointment scheduling
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var avatarGradient: LinearGradient {
        let colors = [Color.blue, Color.purple]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private func severityColor(_ severity: MedicalHistory.AllergySeverity) -> Color {
        switch severity {
        case .mild:
            return .green
        case .moderate:
            return .orange
        case .severe:
            return .red
        case .lifeThreatening:
            return .purple
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct RiskFactorChip: View {
    let title: String
    let active: Bool
    
    var body: some View {
        HStack {
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .foregroundColor(active ? .green : .gray)
                .font(.caption)
            
            Text(title)
                .font(.caption)
                .foregroundColor(active ? .primary : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(active ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Patient View

struct EditPatientView: View {
    let patient: Patient
    @Environment(\.dismiss) private var dismiss
    
    // Edit state
    @State private var firstName: String
    @State private var lastName: String
    @State private var dateOfBirth: Date
    @State private var gender: Gender
    @State private var ethnicity: Ethnicity?
    @State private var skinType: FitzpatrickSkinType?
    @State private var email: String
    @State private var phone: String
    
    init(patient: Patient) {
        self.patient = patient
        self._firstName = State(initialValue: patient.firstName)
        self._lastName = State(initialValue: patient.lastName)
        self._dateOfBirth = State(initialValue: patient.dateOfBirth)
        self._gender = State(initialValue: patient.gender)
        self._ethnicity = State(initialValue: patient.ethnicity)
        self._skinType = State(initialValue: patient.skinType)
        self._email = State(initialValue: patient.contactInfo.email ?? "")
        self._phone = State(initialValue: patient.contactInfo.phone ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender)
                        }
                    }
                    
                    Picker("Ethnicity", selection: $ethnicity) {
                        Text("Not specified").tag(nil as Ethnicity?)
                        ForEach(Ethnicity.allCases, id: \.self) { ethnicity in
                            Text(ethnicity.displayName).tag(ethnicity as Ethnicity?)
                        }
                    }
                    
                    Picker("Skin Type", selection: $skinType) {
                        Text("Not specified").tag(nil as FitzpatrickSkinType?)
                        ForEach(FitzpatrickSkinType.allCases, id: \.self) { skinType in
                            Text(skinType.displayName).tag(skinType as FitzpatrickSkinType?)
                        }
                    }
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
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
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        // TODO: Update patient in view model
        dismiss()
    }
}

// MARK: - Patient Analysis History View

struct PatientAnalysisHistoryView: View {
    let patient: Patient
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent Analyses")) {
                    ForEach(0..<5) { index in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Skin Analysis #\(index + 1)")
                                    .font(.headline)
                                
                                Text("Melanocytic nevus - 87% confidence")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("2 days ago")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Analysis History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Patient Extensions

extension Patient {
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
}

#Preview {
    PatientDetailView(patient: Patient.sampleData[0])
} 
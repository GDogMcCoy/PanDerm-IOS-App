import SwiftUI

/// Detailed view for displaying comprehensive patient information
/// Shows demographics, risk factors, medical history, and PanDerm analysis
struct PatientDetailView: View {
    let patient: Patient
    @ObservedObject var viewModel: PatientViewModel
    @StateObject private var panDermService = PanDermService()
    @State private var selectedTab = 0
    @State private var showingEditPatient = false
    @State private var showingAnalysisResults = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Patient Header
                patientHeader
                
                // Risk Assessment Card
                riskAssessmentCard
                
                // Tab Navigation
                tabNavigation
                
                // Tab Content
                tabContent
            }
            .padding()
        }
        .navigationTitle("Patient Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit Patient") {
                        showingEditPatient = true
                    }
                    
                    Button("PanDerm Analysis") {
                        Task {
                            await viewModel.analyzePatientRisk()
                            showingAnalysisResults = true
                        }
                    }
                    
                    Button("Generate Report") {
                        // TODO: Implement report generation
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditPatient) {
            EditPatientView(patient: patient, viewModel: viewModel)
        }
        .sheet(isPresented: $showingAnalysisResults) {
            PatientAnalysisResultsView(patient: patient, viewModel: viewModel)
        }
        .onAppear {
            viewModel.selectPatient(patient)
        }
    }
    
    // MARK: - Patient Header
    
    private var patientHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(avatarColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(patient.initials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Patient Info
            VStack(spacing: 8) {
                Text(patient.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(patient.age) years • \(patient.gender.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let ethnicity = patient.ethnicity {
                    Text(ethnicity.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Contact Info
            if let email = patient.contactInfo.email {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                    Text(email)
                        .font(.caption)
                }
            }
            
            if let phone = patient.contactInfo.phone {
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.green)
                    Text(phone)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Risk Assessment Card
    
    private var riskAssessmentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Risk Assessment")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                RiskBadge(riskLevel: patient.riskFactors.riskLevel)
            }
            
            // Risk Score
            HStack {
                Text("Risk Score:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(patient.riskFactors.riskScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(riskColor)
                
                Spacer()
            }
            
            // Risk Factors
            if !riskFactorsList.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risk Factors:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(riskFactorsList, id: \.self) { factor in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(factor)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Recommendations
            let recommendations = viewModel.getRiskRecommendations(for: patient)
            if !recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(recommendation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Tab Navigation
    
    private var tabNavigation: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabItems.enumerated()), id: \.offset) { index, item in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 20))
                        Text(item.title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            demographicsTab
        case 1:
            medicalHistoryTab
        case 2:
            skinConditionsTab
        case 3:
            appointmentsTab
        default:
            demographicsTab
        }
    }
    
    // MARK: - Demographics Tab
    
    private var demographicsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Demographics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Medical History Tab
    
    private var medicalHistoryTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medical History")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Family History
                if patient.medicalHistory.familyHistory.melanoma {
                    InfoRow(title: "Family History", value: "Melanoma", isAlert: true)
                }
                
                // Previous Surgeries
                if !patient.medicalHistory.previousSurgeries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Previous Surgeries")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(patient.medicalHistory.previousSurgeries) { surgery in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(surgery.procedure)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(surgery.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading)
                        }
                    }
                }
                
                // Current Medications
                if !patient.medicalHistory.medications.filter({ $0.isActive }).isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Medications")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(patient.medicalHistory.medications.filter { $0.isActive }) { medication in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(medication.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("\(medication.dosage) • \(medication.frequency)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Skin Conditions Tab
    
    private var skinConditionsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skin Conditions")
                .font(.headline)
                .fontWeight(.semibold)
            
            if patient.medicalHistory.previousSkinConditions.isEmpty {
                Text("No previous skin conditions recorded")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(patient.medicalHistory.previousSkinConditions) { condition in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(condition.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(condition.category.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                        
                        Text(condition.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Appointments Tab
    
    private var appointmentsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appointments")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Appointment history will be displayed here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Computed Properties
    
    private var avatarColor: Color {
        switch patient.riskFactors.riskLevel {
        case "Low": return .green
        case "Medium": return .orange
        case "High", "Very High": return .red
        default: return .blue
        }
    }
    
    private var riskColor: Color {
        switch patient.riskFactors.riskLevel {
        case "Low": return .green
        case "Medium": return .orange
        case "High": return .red
        case "Very High": return .purple
        default: return .blue
        }
    }
    
    private var riskFactorsList: [String] {
        var factors: [String] = []
        
        if patient.riskFactors.fairSkin { factors.append("Fair Skin") }
        if patient.riskFactors.lightHair { factors.append("Light Hair") }
        if patient.riskFactors.lightEyes { factors.append("Light Eyes") }
        if patient.riskFactors.freckles { factors.append("Freckles") }
        if patient.riskFactors.manyMoles { factors.append("Many Moles") }
        if patient.riskFactors.atypicalMoles { factors.append("Atypical Moles") }
        if patient.riskFactors.severeSunburns { factors.append("Severe Sunburns") }
        if patient.riskFactors.familyHistory { factors.append("Family History") }
        if patient.riskFactors.personalHistory { factors.append("Personal History") }
        if patient.riskFactors.immunosuppression { factors.append("Immunosuppression") }
        if patient.riskFactors.xerodermaPigmentosum { factors.append("Xeroderma Pigmentosum") }
        
        return factors
    }
    
    private var tabItems: [(title: String, icon: String)] {
        [
            ("Demographics", "person.circle"),
            ("Medical History", "heart.circle"),
            ("Skin Conditions", "camera.circle"),
            ("Appointments", "calendar.circle")
        ]
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let title: String
    let value: String
    var isAlert: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isAlert ? .red : .primary)
        }
    }
}

// MARK: - Placeholder Views

struct EditPatientView: View {
    let patient: Patient
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Patient View")
                    .font(.title)
                    .padding()
                
                Text("This view will contain a form to edit patient information.")
                    .foregroundColor(.secondary)
                
                Spacer()
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
                        // TODO: Implement save functionality
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PatientAnalysisResultsView: View {
    let patient: Patient
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("PanDerm Analysis Results")
                    .font(.title)
                    .padding()
                
                Text("This view will display PanDerm AI analysis results.")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Analysis Results")
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

// MARK: - Preview

struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientDetailView(
                patient: Patient(
                    firstName: "John",
                    lastName: "Smith",
                    dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date()) ?? Date(),
                    gender: .male,
                    contactInfo: ContactInfo(email: "john@example.com")
                ),
                viewModel: PatientViewModel()
            )
        }
    }
} 
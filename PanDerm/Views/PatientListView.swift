THIS SHOULD BE A LINTER ERRORimport SwiftUI

/// Main view for displaying and managing the list of patients
/// Features search, filtering, and navigation to patient details
struct PatientListView: View {
    @StateObject private var viewModel = PatientViewModel()
    @State private var showingAddPatient = false
    @State private var showingSampleDataAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Patient List
                if viewModel.filteredPatients.isEmpty {
                    emptyStateView
                } else {
                    patientList
                }
            }
            .navigationTitle("Patients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sample Data") {
                        showingSampleDataAlert = true
                    }
                    .font(.caption)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPatient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPatient) {
                AddPatientView(viewModel: viewModel)
            }
            .alert("Load Sample Data", isPresented: $showingSampleDataAlert) {
                Button("Load") {
                    viewModel.loadSampleData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will load sample patient data for testing purposes.")
            }
            .onAppear {
                viewModel.loadPatients()
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search patients...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Patient List
    
    private var patientList: some View {
        List {
            ForEach(viewModel.filteredPatients) { patient in
                NavigationLink(destination: PatientDetailView(patient: patient, viewModel: viewModel)) {
                    PatientRowView(patient: patient)
                }
            }
            .onDelete(perform: deletePatients)
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Patients")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first patient to get started with PanDerm analysis.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddPatient = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Patient")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Actions
    
    private func deletePatients(offsets: IndexSet) {
        for index in offsets {
            let patient = viewModel.filteredPatients[index]
            viewModel.deletePatient(patient)
        }
    }
}

// MARK: - Patient Row View

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        HStack(spacing: 12) {
            // Patient Avatar
            Circle()
                .fill(avatarColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(patient.initials)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            // Patient Info
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.fullName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(patient.age) years • \(patient.gender.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let email = patient.contactInfo.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Risk Indicator
            VStack(alignment: .trailing, spacing: 4) {
                RiskBadge(riskLevel: patient.riskFactors.riskLevel)
                
                Text("Risk Score: \(patient.riskFactors.riskScore)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var avatarColor: Color {
        switch patient.riskFactors.riskLevel {
        case "Low": return .green
        case "Medium": return .orange
        case "High", "Very High": return .red
        default: return .blue
        }
    }
}

// MARK: - Risk Badge

struct RiskBadge: View {
    let riskLevel: String
    
    var body: some View {
        Text(riskLevel)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(riskColor.opacity(0.2))
            .foregroundColor(riskColor)
            .cornerRadius(8)
    }
    
    private var riskColor: Color {
        switch riskLevel {
        case "Low": return .green
        case "Medium": return .orange
        case "High": return .red
        case "Very High": return .purple
        default: return .blue
        }
    }
}

// MARK: - Add Patient View (Placeholder)

struct AddPatientView: View {
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Patient View")
                    .font(.title)
                    .padding()
                
                Text("This view will contain a form to add new patients.")
                    .foregroundColor(.secondary)
                
                Spacer()
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
                        // TODO: Implement save functionality
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

// MARK: - Preview

struct PatientListView_Previews: PreviewProvider {
    static var previews: some View {
        PatientListView()
    }
} 
import SwiftUI

/// Main view for displaying and managing the list of patients
/// Features search, filtering, and navigation to patient details
struct PatientListView: View {
    @StateObject private var viewModel = PatientViewModel()
    @State private var searchText = ""
    @State private var showingAddPatient = false
    @State private var selectedPatient: Patient?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Patient List
                List {
                    ForEach(filteredPatients) { patient in
                        PatientRowView(patient: patient)
                            .onTapGesture {
                                selectedPatient = patient
                            }
                    }
                    .onDelete(perform: deletePatients)
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.refreshPatients()
                }
            }
            .navigationTitle("Patients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPatient = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPatient) {
                AddPatientView { newPatient in
                    viewModel.addPatient(newPatient)
                }
            }
            .sheet(item: $selectedPatient) { patient in
                PatientDetailView(patient: patient)
            }
        }
        .task {
            await viewModel.loadPatients()
        }
    }
    
    private var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return viewModel.patients
        } else {
            return viewModel.patients.filter { patient in
                patient.fullName.localizedCaseInsensitiveContains(searchText) ||
                patient.contactInfo.email?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    private func deletePatients(offsets: IndexSet) {
        for index in offsets {
            let patient = filteredPatients[index]
            viewModel.deletePatient(patient)
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search patients...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .font(.caption)
            }
        }
    }
}

// MARK: - Patient Row View

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.fullName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Age: \(patient.age) • \(patient.gender.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let email = patient.contactInfo.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                RiskBadge(level: patient.riskFactors.riskLevel)
                
                Text("Updated \(patient.updatedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Risk Badge

struct RiskBadge: View {
    let level: String
    
    var body: some View {
        Text(level)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch level {
        case "Low":
            return .green.opacity(0.2)
        case "Medium":
            return .orange.opacity(0.2)
        case "High":
            return .red.opacity(0.2)
        case "Very High":
            return .red.opacity(0.4)
        default:
            return .gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch level {
        case "Low":
            return .green
        case "Medium":
            return .orange
        case "High", "Very High":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Add Patient View

struct AddPatientView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Patient) -> Void
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var gender = Gender.preferNotToSay
    @State private var email = ""
    @State private var phone = ""
    
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
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
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
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }
    
    private func savePatient() {
        let contactInfo = ContactInfo(email: email.isEmpty ? nil : email, phone: phone.isEmpty ? nil : phone)
        let newPatient = Patient(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            contactInfo: contactInfo
        )
        onSave(newPatient)
        dismiss()
    }
}

// MARK: - Preview

struct PatientListView_Previews: PreviewProvider {
    static var previews: some View {
        PatientListView()
    }
} 
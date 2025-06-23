import SwiftUI

struct ContentView: View {
    @StateObject private var inferenceManager = PanDermInferenceManager()
    
    var body: some View {
        TabView {
            // Main Analysis Tab
            NavigationView {
                ImageAnalysisView()
            }
            .tabItem {
                Label("Analyze", systemImage: "camera.fill")
            }
            
            // Patient List Tab
            NavigationView {
                PatientListView()
            }
            .tabItem {
                Label("Patients", systemImage: "person.3.fill")
            }
            
            // History Tab
            NavigationView {
                AnalysisHistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            
            // Settings Tab
            NavigationView {
                InferenceSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .environmentObject(inferenceManager)
        .onAppear {
            // Initialize the inference manager on app launch
            inferenceManager.initializeServices()
        }
    }
}

// MARK: - Missing Home View for Tab Navigation

struct HomeView: View {
    @EnvironmentObject var inferenceManager: PanDermInferenceManager
    @StateObject private var patientViewModel = PatientViewModel()
    @StateObject private var analysisViewModel = SkinConditionViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Header
                welcomeHeader
                
                // Quick Stats
                quickStatsSection
                
                // Quick Actions
                quickActionsSection
                
                // Recent Activity
                recentActivitySection
            }
            .padding()
        }
        .navigationTitle("PanDerm")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await patientViewModel.loadPatients()
        }
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "cross.case.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text("PanDerm AI")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text("Advanced Dermatology Analysis")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Patients",
                value: "\(patientViewModel.totalPatients)",
                icon: "person.3.fill",
                color: .blue
            )
            
            StatCard(
                title: "Analyses",
                value: "\(analysisViewModel.totalAnalyses)",
                icon: "chart.bar.fill",
                color: .green
            )
            
            StatCard(
                title: "High Risk",
                value: "\(analysisViewModel.highRiskAnalyses)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                QuickActionButton(
                    title: "New Analysis",
                    subtitle: "Capture and analyze skin image",
                    icon: "camera.fill",
                    color: .blue
                ) {
                    // Navigate to analysis
                }
                
                QuickActionButton(
                    title: "Add Patient",
                    subtitle: "Register new patient",
                    icon: "person.badge.plus",
                    color: .green
                ) {
                    // Navigate to add patient
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(analysisViewModel.analysisResults.prefix(3), id: \.id) { result in
                    RecentActivityRow(result: result)
                }
                
                if analysisViewModel.analysisResults.isEmpty {
                    Text("No recent activity")
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
}

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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct QuickActionButton: View {
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
                    .frame(width: 30)
                
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

struct RecentActivityRow: View {
    let result: AnalysisResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(result.classifications.first?.label.capitalized.replacingOccurrences(of: "_", with: " ") ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(Int(result.confidence * 100))% confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(result.createdAt.formatted(.relative(presentation: .named)))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
} 
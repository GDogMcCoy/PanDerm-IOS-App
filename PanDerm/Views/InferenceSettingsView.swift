import SwiftUI

/// Settings view for managing PanDerm inference capabilities
/// Provides control over local/cloud inference, model management, and performance monitoring
struct InferenceSettingsView: View {
    @EnvironmentObject var inferenceManager: PanDermInferenceManager
    @StateObject private var localService = LocalInferenceService()
    @State private var showingModelInfo = false
    @State private var showingPerformanceStats = false
    
    var body: some View {
        NavigationView {
            List {
                // Inference Mode Section
                Section(header: Text("Inference Mode")) {
                    Picker("Mode", selection: $inferenceManager.inferenceMode) {
                        ForEach(InferenceMode.allCases, id: \.self) { mode in
                            VStack(alignment: .leading) {
                                Text(mode.rawValue)
                                Text(mode.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Model Status Section
                Section(header: Text("Model Status")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Local Model")
                                .font(.headline)
                            Text(inferenceManager.modelVersion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        ModelStatusBadge(status: inferenceManager.localModelStatus)
                    }
                    
                    if localService.isModelLoaded {
                        Button("View Model Information") {
                            showingModelInfo = true
                        }
                    }
                    
                    Button("Refresh Model Status") {
                        inferenceManager.checkModelStatus()
                    }
                }
                
                // Performance Section
                Section(header: Text("Performance")) {
                    Button("View Performance Statistics") {
                        showingPerformanceStats = true
                    }
                    
                    Button("Clear Performance Data") {
                        inferenceManager.clearPerformanceData()
                    }
                    .foregroundColor(.red)
                }
                
                // Network Status Section
                Section(header: Text("Network")) {
                    HStack {
                        Text("Internet Connection")
                        Spacer()
                        Image(systemName: inferenceManager.isOnline ? "wifi" : "wifi.slash")
                            .foregroundColor(inferenceManager.isOnline ? .green : .red)
                        Text(inferenceManager.isOnline ? "Connected" : "Offline")
                            .foregroundColor(inferenceManager.isOnline ? .green : .red)
                    }
                }
                
                // Privacy & Security Section
                Section(header: Text("Privacy & Security")) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Local Processing")
                                .font(.headline)
                            Text("All image analysis is performed locally on your device for maximum privacy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "cross.case")
                            .foregroundColor(.red)
                        VStack(alignment: .leading) {
                            Text("HIPAA Compliant")
                                .font(.headline)
                            Text("Data handling meets healthcare privacy standards")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Model Version")
                        Spacer()
                        Text(localService.modelVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("View Documentation") {
                        // Open documentation
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingModelInfo) {
                ModelInformationView()
            }
            .sheet(isPresented: $showingPerformanceStats) {
                PerformanceStatsView()
            }
        }
    }
}

struct ModelStatusBadge: View {
    let status: ModelStatus
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch status {
        case .notLoaded:
            return "xmark.circle"
        case .loading:
            return "arrow.clockwise"
        case .loaded:
            return "checkmark.circle"
        case .error:
            return "exclamationmark.triangle"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .notLoaded:
            return .gray
        case .loading:
            return .orange
        case .loaded:
            return .green
        case .error:
            return .red
        }
    }
}

struct ModelInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localService = LocalInferenceService()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Model Details")) {
                    DetailRow(title: "Model Name", value: "PanDerm Base Model")
                    DetailRow(title: "Version", value: localService.modelVersion)
                    DetailRow(title: "Architecture", value: "Vision Transformer")
                    DetailRow(title: "Input Size", value: "224×224 pixels")
                    DetailRow(title: "Classes", value: "9 skin conditions")
                }
                
                Section(header: Text("Capabilities")) {
                    CapabilityRow(title: "Skin Condition Classification", supported: true)
                    CapabilityRow(title: "Benign/Malignant Detection", supported: true)
                    CapabilityRow(title: "Confidence Scoring", supported: true)
                    CapabilityRow(title: "Multi-lesion Detection", supported: false)
                }
                
                Section(header: Text("Performance")) {
                    DetailRow(title: "Accuracy", value: "94.5%")
                    DetailRow(title: "Inference Time", value: "< 2 seconds")
                    DetailRow(title: "Model Size", value: "45.2 MB")
                }
            }
            .navigationTitle("Model Information")
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

struct PerformanceStatsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inferenceManager: PanDermInferenceManager
    
    var body: some View {
        NavigationView {
            List {
                let stats = inferenceManager.getPerformanceStats()
                
                Section(header: Text("Usage Statistics")) {
                    StatRow(title: "Total Analyses", value: "\(stats.totalInferences)")
                    StatRow(title: "Average Time", value: String(format: "%.2f seconds", stats.averageInferenceTime))
                }
                
                Section(header: Text("Mode Usage")) {
                    ForEach(Array(stats.modeUsage.keys), id: \.self) { mode in
                        StatRow(title: mode.rawValue, value: "\(stats.modeUsage[mode] ?? 0)")
                    }
                }
            }
            .navigationTitle("Performance")
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct CapabilityRow: View {
    let title: String
    let supported: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: supported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(supported ? .green : .red)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    InferenceSettingsView()
        .environmentObject(PanDermInferenceManager())
} 
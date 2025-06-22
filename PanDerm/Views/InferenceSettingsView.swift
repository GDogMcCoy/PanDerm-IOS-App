import SwiftUI

/// Settings view for managing PanDerm inference capabilities
/// Provides control over local/cloud inference, model management, and performance monitoring
struct InferenceSettingsView: View {
    @StateObject private var inferenceManager = PanDermInferenceManager()
    @State private var showingModelDownload = false
    @State private var showingModelUpdate = false
    @State private var showingPerformanceStats = false
    @State private var selectedInferenceMode: InferenceMode = .automatic
    
    var body: some View {
        NavigationView {
            List {
                // Inference Mode Section
                inferenceModeSection
                
                // Model Management Section
                modelManagementSection
                
                // Performance Section
                performanceSection
                
                // Network Status Section
                networkStatusSection
                
                // Advanced Settings Section
                advancedSettingsSection
            }
            .navigationTitle("Inference Settings")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshStatus()
            }
            .alert("Download Model", isPresented: $showingModelDownload) {
                Button("Download") {
                    Task {
                        await downloadModel()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will download the PanDerm model for offline use. This may take several minutes and requires a stable internet connection.")
            }
            .alert("Update Model", isPresented: $showingModelUpdate) {
                Button("Update") {
                    Task {
                        await updateModel()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will update your local PanDerm model to the latest version.")
            }
            .sheet(isPresented: $showingPerformanceStats) {
                PerformanceStatsView(inferenceManager: inferenceManager)
            }
        }
    }
    
    // MARK: - Inference Mode Section
    
    private var inferenceModeSection: some View {
        Section("Inference Mode") {
            ForEach(InferenceMode.allCases, id: \.self) { mode in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(mode.rawValue)
                                .font(.headline)
                            
                            if mode == inferenceManager.inferenceMode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text(mode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if mode == .local && inferenceManager.localModelStatus != .loaded {
                        Text(inferenceManager.localModelStatus.rawValue)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedInferenceMode = mode
                    inferenceManager.inferenceMode = mode
                }
            }
        }
    }
    
    // MARK: - Model Management Section
    
    private var modelManagementSection: some View {
        Section("Model Management") {
            // Model Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local Model Status")
                        .font(.headline)
                    Text(inferenceManager.localModelStatus.rawValue)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                if inferenceManager.inferenceProgress > 0 && inferenceManager.inferenceProgress < 1.0 {
                    ProgressView(value: inferenceManager.inferenceProgress)
                        .frame(width: 60)
                }
            }
            
            // Current Operation
            if !inferenceManager.currentOperation.isEmpty {
                HStack {
                    Text("Current Operation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(inferenceManager.currentOperation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Model Version
            HStack {
                Text("Model Version")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(inferenceManager.modelVersion)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Download Model Button
            Button(action: { showingModelDownload = true }) {
                HStack {
                    Image(systemName: "arrow.down.circle")
                    Text("Download Model")
                }
            }
            .disabled(!inferenceManager.isOnline)
            
            // Update Model Button
            Button(action: { showingModelUpdate = true }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle")
                    Text("Update Model")
                }
            }
            .disabled(!inferenceManager.isOnline || inferenceManager.localModelStatus != .loaded)
        }
    }
    
    // MARK: - Performance Section
    
    private var performanceSection: some View {
        Section("Performance") {
            Button(action: { showingPerformanceStats = true }) {
                HStack {
                    Image(systemName: "chart.bar")
                    Text("View Performance Statistics")
                }
            }
            
            Button(action: {
                inferenceManager.clearPerformanceData()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear Performance Data")
                }
                .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Network Status Section
    
    private var networkStatusSection: some View {
        Section("Network Status") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Internet Connection")
                        .font(.headline)
                    Text(inferenceManager.isOnline ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundColor(inferenceManager.isOnline ? .green : .red)
                }
                
                Spacer()
                
                Image(systemName: inferenceManager.isOnline ? "wifi" : "wifi.slash")
                    .foregroundColor(inferenceManager.isOnline ? .green : .red)
            }
            
            if !inferenceManager.isOnline {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Offline mode enabled - limited functionality available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Advanced Settings Section
    
    private var advancedSettingsSection: some View {
        Section("Advanced Settings") {
            NavigationLink(destination: AdvancedInferenceSettingsView()) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Advanced Settings")
                }
            }
            
            NavigationLink(destination: ModelInfoView()) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Model Information")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var statusColor: Color {
        switch inferenceManager.localModelStatus {
        case .loaded, .updated:
            return .green
        case .loading, .updating:
            return .orange
        case .error:
            return .red
        default:
            return .secondary
        }
    }
    
    private func refreshStatus() async {
        // Refresh network status and model status
        inferenceManager.updateInferenceMode()
    }
    
    private func downloadModel() async {
        do {
            try await inferenceManager.downloadModel()
        } catch {
            inferenceManager.errorMessage = "Failed to download model: \(error.localizedDescription)"
        }
    }
    
    private func updateModel() async {
        do {
            try await inferenceManager.updateLocalModel()
        } catch {
            inferenceManager.errorMessage = "Failed to update model: \(error.localizedDescription)"
        }
    }
}

// MARK: - Performance Stats View

struct PerformanceStatsView: View {
    @ObservedObject var inferenceManager: PanDermInferenceManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                let stats = inferenceManager.getPerformanceStats()
                
                Section("Inference Performance") {
                    StatRow(title: "Total Inferences", value: "\(stats.totalInferences)")
                    StatRow(title: "Average Time", value: formatTime(stats.averageInferenceTime))
                    StatRow(title: "Total Risk Analyses", value: "\(stats.totalRiskAnalyses)")
                    StatRow(title: "Average Risk Analysis Time", value: formatTime(stats.averageRiskAnalysisTime))
                    StatRow(title: "Total Change Detections", value: "\(stats.totalChangeDetections)")
                    StatRow(title: "Average Change Detection Time", value: formatTime(stats.averageChangeDetectionTime))
                }
                
                Section("Mode Usage") {
                    ForEach(InferenceMode.allCases, id: \.self) { mode in
                        let count = stats.modeUsage[mode] ?? 0
                        StatRow(title: mode.rawValue, value: "\(count) uses")
                    }
                }
                
                Section("Performance Insights") {
                    PerformanceInsightView(stats: stats)
                }
            }
            .navigationTitle("Performance Statistics")
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
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval < 1.0 {
            return String(format: "%.2f ms", timeInterval * 1000)
        } else {
            return String(format: "%.2f s", timeInterval)
        }
    }
}

// MARK: - Supporting Views

struct StatRow: View {
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

struct PerformanceInsightView: View {
    let stats: PerformanceStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if stats.totalInferences > 0 {
                let fastestMode = stats.modeUsage.min { a, b in
                    stats.modeUsage[a.key] ?? 0 < stats.modeUsage[b.key] ?? 0
                }?.key
                
                if let fastest = fastestMode {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("Most used mode: \(fastest.rawValue)")
                            .font(.caption)
                    }
                }
                
                if stats.averageInferenceTime < 2.0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Good performance - average inference time under 2 seconds")
                            .font(.caption)
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Consider optimizing - average inference time over 2 seconds")
                            .font(.caption)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("No performance data available yet")
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Advanced Settings View

struct AdvancedInferenceSettingsView: View {
    @AppStorage("enableGPUAcceleration") private var enableGPUAcceleration = true
    @AppStorage("enableModelCaching") private var enableModelCaching = true
    @AppStorage("maxBatchSize") private var maxBatchSize = 5
    @AppStorage("inferenceTimeout") private var inferenceTimeout = 30.0
    
    var body: some View {
        List {
            Section("Hardware Acceleration") {
                Toggle("Enable GPU Acceleration", isOn: $enableGPUAcceleration)
                
                if enableGPUAcceleration {
                    Text("Uses Metal Performance Shaders for faster inference")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Caching & Performance") {
                Toggle("Enable Model Caching", isOn: $enableModelCaching)
                
                VStack(alignment: .leading) {
                    Text("Maximum Batch Size: \(maxBatchSize)")
                    Slider(value: Binding(
                        get: { Double(maxBatchSize) },
                        set: { maxBatchSize = Int($0) }
                    ), in: 1...10, step: 1)
                }
                
                VStack(alignment: .leading) {
                    Text("Inference Timeout: \(String(format: "%.1f", inferenceTimeout))s")
                    Slider(value: $inferenceTimeout, in: 10...60, step: 5)
                }
            }
            
            Section("Model Configuration") {
                NavigationLink("Model Parameters") {
                    ModelParametersView()
                }
                
                NavigationLink("Preprocessing Settings") {
                    PreprocessingSettingsView()
                }
            }
        }
        .navigationTitle("Advanced Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Placeholder Views

struct ModelInfoView: View {
    var body: some View {
        List {
            Section("Model Details") {
                InfoRow(title: "Model Name", value: "PanDerm Foundation Model")
                InfoRow(title: "Version", value: "v1.0.0")
                InfoRow(title: "Architecture", value: "Vision Transformer")
                InfoRow(title: "Parameters", value: "1.2B")
                InfoRow(title: "Input Size", value: "512x512")
                InfoRow(title: "Output Classes", value: "15")
            }
            
            Section("Capabilities") {
                Text("• Skin cancer classification")
                Text("• Lesion segmentation")
                Text("• Risk assessment")
                Text("• Change detection")
                Text("• Multi-modal analysis")
            }
            
            Section("Performance") {
                InfoRow(title: "Accuracy", value: "94.2%")
                InfoRow(title: "Sensitivity", value: "96.1%")
                InfoRow(title: "Specificity", value: "92.8%")
                InfoRow(title: "AUC", value: "0.97")
            }
        }
        .navigationTitle("Model Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ModelParametersView: View {
    var body: some View {
        Text("Model Parameters Configuration")
            .navigationTitle("Model Parameters")
    }
}

struct PreprocessingSettingsView: View {
    var body: some View {
        Text("Preprocessing Settings")
            .navigationTitle("Preprocessing")
    }
}

// MARK: - Preview

struct InferenceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceSettingsView()
    }
} 
import SwiftUI

/// Settings view for managing PanDerm inference capabilities
/// Provides control over local/cloud inference, model management, and performance monitoring
struct InferenceSettingsView: View {
    @EnvironmentObject private var inferenceManager: PanDermInferenceManager
    @State private var showingModelDownload = false
    @State private var showingPerformanceStats = false
    @State private var showingAbout = false
    
    var body: some View {
        Form {
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
                .pickerStyle(.automatic)
                
                Text("Automatic mode intelligently chooses between local and cloud inference based on availability and performance.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Model Status Section
            Section(header: Text("Model Status")) {
                HStack {
                    Label("Local Model", systemImage: "cpu")
                    Spacer()
                    ModelStatusBadge(status: inferenceManager.localModelStatus)
                }
                
                if inferenceManager.localModelStatus == .loaded {
                    HStack {
                        Text("Model Version")
                        Spacer()
                        Text(inferenceManager.modelVersion)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label("Network Status", systemImage: "network")
                    Spacer()
                    Image(systemName: inferenceManager.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(inferenceManager.isOnline ? .green : .red)
                }
            }
            
            // Performance Section
            Section(header: Text("Performance")) {
                Button(action: {
                    showingPerformanceStats = true
                }) {
                    HStack {
                        Label("Performance Statistics", systemImage: "chart.bar.fill")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {
                    inferenceManager.clearPerformanceData()
                }) {
                    Label("Clear Performance Data", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Model Management Section
            Section(header: Text("Model Management")) {
                Button(action: {
                    Task {
                        await inferenceManager.checkModelStatus()
                    }
                }) {
                    Label("Refresh Model Status", systemImage: "arrow.clockwise")
                }
                
                Button(action: {
                    showingModelDownload = true
                }) {
                    Label("Download Latest Model", systemImage: "arrow.down.circle")
                }
                .disabled(inferenceManager.localModelStatus == .loading)
            }
            
            // Data Management Section
            Section(header: Text("Data Management")) {
                HStack {
                    Text("Analysis History")
                    Spacer()
                    Text("\(inferenceManager.recentAnalyses.count) items")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    clearAnalysisHistory()
                }) {
                    Label("Clear Analysis History", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .disabled(inferenceManager.recentAnalyses.isEmpty)
            }
            
            // App Information Section
            Section(header: Text("About")) {
                Button(action: {
                    showingAbout = true
                }) {
                    HStack {
                        Label("About PanDerm", systemImage: "info.circle")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingPerformanceStats) {
            PerformanceStatsView()
        }
        .sheet(isPresented: $showingModelDownload) {
            ModelDownloadView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func clearAnalysisHistory() {
        inferenceManager.recentAnalyses.removeAll()
    }
}

struct ModelStatusBadge: View {
    let status: ModelStatus
    
    var body: some View {
        HStack(spacing: 4) {
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
        case .loaded:
            return "checkmark.circle.fill"
        case .loading:
            return "arrow.clockwise"
        case .error:
            return "exclamationmark.triangle.fill"
        case .notLoaded:
            return "questionmark.circle"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .loaded:
            return .green
        case .loading:
            return .orange
        case .error:
            return .red
        case .notLoaded:
            return .gray
        }
    }
}

struct PerformanceStatsView: View {
    @EnvironmentObject private var inferenceManager: PanDermInferenceManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    let stats = inferenceManager.getPerformanceStats()
                    
                    // Inference Statistics
                    StatCard(
                        title: "Total Inferences",
                        value: "\(stats.totalInferences)",
                        subtitle: "Completed analyses",
                        icon: "brain.head.profile"
                    )
                    
                    StatCard(
                        title: "Average Inference Time",
                        value: String(format: "%.2f sec", stats.averageInferenceTime),
                        subtitle: "Per analysis",
                        icon: "stopwatch"
                    )
                    
                    // Mode Usage Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inference Mode Usage")
                            .font(.headline)
                        
                        ForEach(InferenceMode.allCases, id: \.self) { mode in
                            let usage = stats.modeUsage[mode] ?? 0
                            let percentage = stats.totalInferences > 0 ? Double(usage) / Double(stats.totalInferences) : 0
                            
                            HStack {
                                Text(mode.rawValue)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(usage)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressView(value: percentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Performance Stats")
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

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ModelDownloadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var downloadProgress: Double = 0.0
    @State private var isDownloading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Download Latest Model")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Download the latest PanDerm AI model for improved accuracy and new features.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if isDownloading {
                    VStack(spacing: 12) {
                        ProgressView(value: downloadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("Downloading... \(Int(downloadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    startDownload()
                }) {
                    Text(isDownloading ? "Downloading..." : "Download Model")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isDownloading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isDownloading)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Model Download")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(isDownloading)
                }
            }
        }
    }
    
    private func startDownload() {
        isDownloading = true
        downloadProgress = 0.0
        
        // Simulate download progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            downloadProgress += 0.05
            
            if downloadProgress >= 1.0 {
                timer.invalidate()
                isDownloading = false
                downloadProgress = 1.0
                
                // Auto-dismiss after completion
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("PanDerm AI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Advanced Dermatological Analysis")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        AboutSection(
                            title: "About PanDerm",
                            content: "PanDerm uses advanced AI technology to assist in dermatological analysis. Our models are trained on extensive datasets to help identify various skin conditions with high accuracy."
                        )
                        
                        AboutSection(
                            title: "Features",
                            content: "• Local AI inference on-device\n• Multi-class skin condition classification\n• Real-time analysis with confidence scores\n• Comprehensive analysis history\n• Performance monitoring and optimization"
                        )
                        
                        AboutSection(
                            title: "Disclaimer",
                            content: "This app is for educational and informational purposes only. It should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always consult with a qualified healthcare provider."
                        )
                    }
                    
                    VStack(spacing: 8) {
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2024 PanDerm Technologies")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("About")
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

struct AboutSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        InferenceSettingsView()
    }
    .environmentObject(PanDermInferenceManager())
} 
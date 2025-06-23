import SwiftUI

struct AnalysisHistoryView: View {
    @EnvironmentObject private var inferenceManager: PanDermInferenceManager
    @State private var selectedSession: AnalysisSession?
    @State private var showingSessionDetail = false
    
    var body: some View {
        List {
            if inferenceManager.recentAnalyses.isEmpty {
                emptyStateView
            } else {
                ForEach(inferenceManager.recentAnalyses) { session in
                    AnalysisHistoryRow(session: session)
                        .onTapGesture {
                            selectedSession = session
                            showingSessionDetail = true
                        }
                }
                .onDelete(perform: deleteAnalyses)
            }
        }
        .navigationTitle("Analysis History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !inferenceManager.recentAnalyses.isEmpty {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingSessionDetail) {
            if let session = selectedSession {
                NavigationView {
                    AnalysisSessionDetailView(session: session)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingSessionDetail = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Analysis History")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Your analysis history will appear here after you analyze skin images")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Switch to analysis tab
            }) {
                Label("Start Analyzing", systemImage: "camera.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowSeparator(.hidden)
    }
    
    private func deleteAnalyses(at offsets: IndexSet) {
        inferenceManager.recentAnalyses.remove(atOffsets: offsets)
    }
}

struct AnalysisHistoryRow: View {
    let session: AnalysisSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let image = UIImage(data: session.image.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Top classification
                if let topResult = session.result.classifications.first {
                    Text(topResult.label.capitalized.replacingOccurrences(of: "_", with: " "))
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(Int(topResult.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Date and mode
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
}

struct AnalysisSessionDetailView: View {
    let session: AnalysisSession
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image
                if let image = UIImage(data: session.image.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                }
                
                // Session Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Analysis Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    InfoRow(title: "Date", value: session.formattedDate)
                    InfoRow(title: "Mode", value: session.inferenceMode.rawValue)
                    InfoRow(title: "Model Version", value: session.modelVersion)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Classifications
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Classifications")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ForEach(session.result.classifications.prefix(5)) { classification in
                        ClassificationDetailRow(classification: classification)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Analysis Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ClassificationDetailRow: View {
    let classification: ClassificationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(classification.label.capitalized.replacingOccurrences(of: "_", with: " "))
                    .font(.headline)
                Spacer()
                Text("\(Int(classification.confidence * 100))%")
                    .font(.headline)
                    .foregroundColor(confidenceColor)
            }
            
            ProgressView(value: classification.confidence)
                .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor))
            
            if !classification.details.isEmpty {
                Text(classification.details)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private var confidenceColor: Color {
        switch classification.confidence {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    NavigationView {
        AnalysisHistoryView()
    }
    .environmentObject(PanDermInferenceManager())
}
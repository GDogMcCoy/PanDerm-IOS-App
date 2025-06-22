import SwiftUI
import UIKit
import PhotosUI

/// Comprehensive image analysis view with local inference integration
/// Handles image capture, analysis, and results display for skin conditions
struct ImageAnalysisView: View {
    @StateObject private var viewModel = SkinConditionViewModel()
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingAnalysisResults = false
    @State private var selectedBodyLocation: BodyLocation = .face
    @State private var selectedImageType: ImageType = .clinical
    @State private var analysisNotes = ""
    @State private var showingInferenceSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Image Capture Section
                    imageCaptureSection
                    
                    // Analysis Configuration Section
                    analysisConfigurationSection
                    
                    // Captured Images Section
                    if !viewModel.capturedImages.isEmpty {
                        capturedImagesSection
                    }
                    
                    // Analysis Results Section
                    if !viewModel.analysisResults.isEmpty {
                        analysisResultsSection
                    }
                    
                    // Inference Status Section
                    inferenceStatusSection
                }
                .padding()
            }
            .navigationTitle("Image Analysis")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingInferenceSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingInferenceSettings) {
                InferenceSettingsView()
            }
            .sheet(isPresented: $showingAnalysisResults) {
                AnalysisResultsView(viewModel: viewModel)
            }
            .alert("Analysis Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("PanDerm AI Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Capture and analyze skin images with local AI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Inference Mode Indicator
            HStack {
                Image(systemName: inferenceModeIcon)
                    .foregroundColor(inferenceModeColor)
                
                Text("\(viewModel.inferenceMode) Mode")
                    .font(.caption)
                    .fontWeight(.medium)
                
                if viewModel.isLocalModelAvailable {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Image Capture Section
    
    private var imageCaptureSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Capture Images")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Camera Button
                Button(action: { showingCamera = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera")
                            .font(.title2)
                        Text("Camera")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Photo Library Button
                PhotosPicker(selection: $selectedImages, maxSelectionCount: 10, matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                        Text("Library")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            // Image Count
            if !viewModel.capturedImages.isEmpty {
                HStack {
                    Text("\(viewModel.capturedImages.count) images captured")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Clear All") {
                        viewModel.clearImages()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .onChange(of: selectedImages) { items in
            Task {
                await loadSelectedImages(items)
            }
        }
    }
    
    // MARK: - Analysis Configuration Section
    
    private var analysisConfigurationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Analysis Settings")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Body Location Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Location")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Body Location", selection: $selectedBodyLocation) {
                        ForEach(BodyLocation.allCases, id: \.self) { location in
                            Text(location.rawValue).tag(location)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Image Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Image Type")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Image Type", selection: $selectedImageType) {
                        ForEach(ImageType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Analysis Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Add analysis notes...", text: $analysisNotes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
            
            // Analyze Button
            Button(action: {
                Task {
                    await viewModel.analyzeImages()
                    showingAnalysisResults = true
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "brain.head.profile")
                    }
                    
                    Text(viewModel.isLoading ? "Analyzing..." : "Analyze Images")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.capturedImages.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.capturedImages.isEmpty || viewModel.isLoading)
        }
    }
    
    // MARK: - Captured Images Section
    
    private var capturedImagesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Captured Images")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(viewModel.capturedImages) { image in
                    CapturedImageView(image: image) {
                        viewModel.removeImage(image)
                    }
                }
            }
        }
    }
    
    // MARK: - Analysis Results Section
    
    private var analysisResultsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Analysis Results")
                    .font(.headline)
                Spacer()
                
                Button("View Details") {
                    showingAnalysisResults = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if let latestResult = viewModel.analysisResults.last {
                AnalysisResultCard(result: latestResult)
            }
        }
    }
    
    // MARK: - Inference Status Section
    
    private var inferenceStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Inference Status")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                // Current Operation
                if !viewModel.currentOperation.isEmpty {
                    HStack {
                        Text("Status:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.currentOperation)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                }
                
                // Progress Bar
                if viewModel.inferenceProgress > 0 && viewModel.inferenceProgress < 1.0 {
                    ProgressView(value: viewModel.inferenceProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                
                // Network Status
                HStack {
                    Image(systemName: viewModel.isOnline ? "wifi" : "wifi.slash")
                        .foregroundColor(viewModel.isOnline ? .green : .red)
                    
                    Text(viewModel.isOnline ? "Online" : "Offline")
                        .font(.caption)
                        .foregroundColor(viewModel.isOnline ? .green : .red)
                    
                    Spacer()
                    
                    if viewModel.isLocalModelAvailable {
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                            Text("Local Model")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Methods
    
    private var inferenceModeIcon: String {
        switch viewModel.inferenceMode {
        case "Local":
            return "brain.head.profile"
        case "Cloud":
            return "cloud"
        case "Offline":
            return "wifi.slash"
        default:
            return "gear"
        }
    }
    
    private var inferenceModeColor: Color {
        switch viewModel.inferenceMode {
        case "Local":
            return .blue
        case "Cloud":
            return .green
        case "Offline":
            return .orange
        default:
            return .gray
        }
    }
    
    private func loadSelectedImages(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                viewModel.addImage(uiImage, type: selectedImageType, bodyLocation: selectedBodyLocation)
            }
        }
    }
}

// MARK: - Supporting Views

struct CapturedImageView: View {
    let image: SkinImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: image.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .padding(4)
        }
    }
}

struct AnalysisResultCard: View {
    let result: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Analysis Result")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(result.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(confidenceColor)
            }
            
            if let finding = result.findings.first {
                Text(finding.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(result.analysisType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(result.modelVersion)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var confidenceColor: Color {
        if result.confidence > 0.8 {
            return .green
        } else if result.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct AnalysisResultsView: View {
    @ObservedObject var viewModel: SkinConditionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Overall Assessment") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Risk Level:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(viewModel.getOverallRiskLevel())
                                .font(.headline)
                                .foregroundColor(riskColor)
                        }
                        
                        if !viewModel.getCriticalFindings().isEmpty {
                            Text("Critical findings detected")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Findings") {
                    ForEach(viewModel.analysisResults.flatMap { $0.findings }, id: \.id) { finding in
                        FindingRow(finding: finding)
                    }
                }
                
                Section("Recommendations") {
                    ForEach(viewModel.getRecommendations(), id: \.id) { recommendation in
                        RecommendationRow(recommendation: recommendation)
                    }
                }
                
                Section("Analysis Details") {
                    ForEach(viewModel.analysisResults, id: \.id) { result in
                        AnalysisDetailRow(result: result)
                    }
                }
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
    
    private var riskColor: Color {
        switch viewModel.getOverallRiskLevel() {
        case "High":
            return .red
        case "Medium":
            return .orange
        case "Low":
            return .green
        default:
            return .gray
        }
    }
}

struct FindingRow: View {
    let finding: Finding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(finding.description)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(finding.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(confidenceColor)
            }
            
            HStack {
                Text(finding.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.2))
                    .foregroundColor(categoryColor)
                    .cornerRadius(4)
                
                Text(finding.severity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(severityColor.opacity(0.2))
                    .foregroundColor(severityColor)
                    .cornerRadius(4)
                
                Spacer()
            }
        }
    }
    
    private var confidenceColor: Color {
        if finding.confidence > 0.8 {
            return .green
        } else if finding.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var categoryColor: Color {
        switch finding.category {
        case .malignant:
            return .red
        case .suspicious:
            return .orange
        case .benign:
            return .green
        case .other:
            return .gray
        }
    }
    
    private var severityColor: Color {
        switch finding.severity {
        case .severe:
            return .red
        case .moderate:
            return .orange
        case .mild:
            return .green
        }
    }
}

struct RecommendationRow: View {
    let recommendation: Recommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recommendation.action)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Text(recommendation.priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .cornerRadius(4)
                
                Text(recommendation.timeframe)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if !recommendation.rationale.isEmpty {
                Text(recommendation.rationale)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
}

struct AnalysisDetailRow: View {
    let result: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.analysisType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(result.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            Text("Model: \(result.modelVersion)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Date: \(result.analysisDate, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

struct ImageAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        ImageAnalysisView()
    }
} 
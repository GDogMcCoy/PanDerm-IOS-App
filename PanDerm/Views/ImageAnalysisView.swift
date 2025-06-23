import SwiftUI
import UIKit
import PhotosUI

/// Main view for capturing images and initiating skin analysis.
struct ImageAnalysisView: View {
    // Environment objects
    @EnvironmentObject private var inferenceManager: PanDermInferenceManager
    
    // ViewModels
    @StateObject private var viewModel = SkinConditionViewModel()
    
    // State
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingAnalysisResults = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced header with real-time status
                headerView
                
                // Image Display Section
                if let image = selectedImage {
                    imageDisplaySection(image: image)
                } else {
                    imagePlaceholderView
                }
                
                // Real-time analysis progress
                if viewModel.isAnalyzing {
                    analysisProgressSection
                }
                
                // Recent analysis results preview
                if !viewModel.isAnalyzing && viewModel.analysisResult != nil {
                    quickResultsPreview
                }
                
                Spacer()
                
                // Action Buttons
                actionButtons
            }
            .navigationTitle("PanDerm AI")
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $showingImagePicker) {
                ActionSheet(
                    title: Text("Select Image Source"),
                    buttons: [
                        .default(Text("Camera")) {
                            sourceType = .camera
                            showingCamera = true
                        },
                        .default(Text("Photo Library")) {
                            sourceType = .photoLibrary
                            showingCamera = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
            .sheet(isPresented: $showingAnalysisResults) {
                if let result = viewModel.analysisResult {
                    DetailedAnalysisResultsView(result: result)
                }
            }
            .alert("Analysis Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            })
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Skin Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(inferenceManager.localModelStatus == .loaded ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Inference mode indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text(inferenceManager.inferenceMode.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    
                    if inferenceManager.inferenceProgress > 0 && inferenceManager.inferenceProgress < 1 {
                        ProgressView(value: inferenceManager.inferenceProgress)
                            .frame(width: 60)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func imageDisplaySection(image: UIImage) -> some View {
        VStack(spacing: 16) {
            // Image with overlay indicators
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    )
                
                // Analysis status overlay
                if viewModel.isAnalyzing {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Analyzing...")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding()
                }
            }
            
            // Image metadata
            VStack(spacing: 4) {
                HStack {
                    Text("Image Selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(image.size.width))×\(Int(image.size.height))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let jpegData = image.jpegData(compressionQuality: 1.0) {
                    HStack {
                        Text("Size")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(ByteCountFormatter.string(fromByteCount: Int64(jpegData.count), countStyle: .file))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var imagePlaceholderView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("Take or Select Photo")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("Capture a clear photo of the skin area you'd like to analyze")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Quick tips
            VStack(alignment: .leading, spacing: 8) {
                Text("Tips for best results:")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                QuickTip(icon: "lightbulb", text: "Use good lighting")
                QuickTip(icon: "camera.macro", text: "Keep camera steady")
                QuickTip(icon: "viewfinder", text: "Fill frame with skin area")
                QuickTip(icon: "ruler", text: "Include scale reference if possible")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
    
    private var analysisProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Analysis in Progress")
                    .font(.headline)
                
                Spacer()
                
                Text(inferenceManager.currentOperation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: inferenceManager.inferenceProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("Please wait...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(inferenceManager.inferenceProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var quickResultsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Results")
                    .font(.headline)
                
                Spacer()
                
                Button("View Details") {
                    showingAnalysisResults = true
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            if let result = viewModel.analysisResult {
                ForEach(result.classifications.prefix(3)) { classification in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(classification.label.capitalized.replacingOccurrences(of: "_", with: " "))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ProgressView(value: classification.confidence)
                                .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor(classification.confidence)))
                        }
                        
                        Spacer()
                        
                        Text("\(Int(classification.confidence * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(confidenceColor(classification.confidence))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingImagePicker = true
            }) {
                Label("Capture or Select Image", systemImage: "camera.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            if selectedImage != nil {
                Button(action: {
                    analyzeSelectedImage()
                }) {
                    Label(viewModel.isAnalyzing ? "Analyzing..." : "Analyze Image", 
                          systemImage: viewModel.isAnalyzing ? "hourglass" : "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isAnalyzing ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.isAnalyzing)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Views
    
    private struct QuickTip: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var statusText: String {
        switch inferenceManager.localModelStatus {
        case .loaded:
            return "Model Ready • \(inferenceManager.modelVersion)"
        case .loading:
            return "Loading Model..."
        case .error:
            return "Model Error"
        case .notLoaded:
            return "Model Not Available"
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .orange
        default:
            return .red
        }
    }
    
    private func analyzeSelectedImage() {
        guard let imageToAnalyze = selectedImage else {
            viewModel.errorMessage = "Please select an image first."
            return
        }
        
        Task {
            do {
                let result = try await inferenceManager.analyzeImage(imageToAnalyze)
                await MainActor.run {
                    viewModel.analysisResult = result
                    viewModel.isAnalyzing = false
                    viewModel.errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    viewModel.errorMessage = "Analysis failed: \(error.localizedDescription)"
                    viewModel.isAnalyzing = false
                }
            }
        }
        
        viewModel.isAnalyzing = true
    }
}

// MARK: - Enhanced Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        
        if sourceType == .camera {
            picker.cameraDevice = .rear
            picker.cameraFlashMode = .auto
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Enhanced Results View

struct DetailedAnalysisResultsView: View {
    let result: AnalysisResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with confidence indicator
                    VStack(spacing: 12) {
                        HStack {
                            Text("Analysis Complete")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if let topResult = result.classifications.first {
                                ConfidenceBadge(confidence: topResult.confidence)
                            }
                        }
                        
                        if let topResult = result.classifications.first {
                            Text("Top Result: \(topResult.label.capitalized.replacingOccurrences(of: "_", with: " "))")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // All Classifications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Classifications")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        ForEach(result.classifications) { classification in
                            ClassificationDetailRow(classification: classification)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Medical Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            Text("Medical Disclaimer")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        Text("This analysis is for informational purposes only and should not replace professional medical advice. Please consult with a healthcare provider for proper diagnosis and treatment.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
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

struct ConfidenceBadge: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: confidenceIcon)
                .foregroundColor(confidenceColor)
            
            Text("\(Int(confidence * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(confidenceColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var confidenceIcon: String {
        switch confidence {
        case 0.8...1.0:
            return "checkmark.circle.fill"
        case 0.6..<0.8:
            return "exclamationmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private var confidenceColor: Color {
        switch confidence {
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
    ImageAnalysisView()
        .environmentObject(PanDermInferenceManager())
} 
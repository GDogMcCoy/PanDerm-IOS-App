import SwiftUI
import UIKit
import PhotosUI

/// Main view for capturing images and initiating skin analysis.
struct ImageAnalysisView: View {
    // ViewModels
    @StateObject private var viewModel = SkinConditionViewModel()
    @StateObject private var inferenceService = LocalInferenceService()
    
    // State
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAnalysisResults = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                headerView
                
                Spacer()
                
                // Image Display or Placeholder
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                } else {
                    imagePlaceholderView
                }
                
                Spacer()
                
                // Action Buttons
                actionButtons
            }
            .navigationTitle("PanDerm AI")
            .sheet(isPresented: $showingImagePicker, onDismiss: analyzeSelectedImage) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingAnalysisResults) {
                if let result = viewModel.analysisResult {
                    // Pass the result to a dedicated results view
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
        VStack {
            Text("Skin Image Analysis")
                .font(.title2).bold()
            
            HStack {
                Image(systemName: inferenceService.isModelLoaded ? "checkmark.circle.fill" : "hourglass.circle")
                    .foregroundColor(inferenceService.isModelLoaded ? .green : .orange)
                Text(inferenceService.currentOperation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 2)
            
            if !inferenceService.isModelLoaded && inferenceService.inferenceProgress > 0 {
                ProgressView(value: inferenceService.inferenceProgress)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    private var imagePlaceholderView: some View {
        VStack {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("Select an image to analyze")
                .font(.headline)
                .padding(.top)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingImagePicker = true
            }) {
                Label("Choose Image", systemImage: "photo.fill")
                    .frame(maxWidth: .infinity)
            }
            .tint(.blue)
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                analyzeSelectedImage()
            }) {
                Label("Analyze Image", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .tint(.green)
            .buttonStyle(.borderedProminent)
            .disabled(selectedImage == nil || viewModel.isAnalyzing)
        }
        .padding()
    }
    
    // MARK: - Functions
    
    private func analyzeSelectedImage() {
        guard let imageToAnalyze = selectedImage else {
            viewModel.errorMessage = "Please select an image first."
            return
        }
        
        Task {
            await viewModel.analyzeImage(imageToAnalyze, using: inferenceService)
            if viewModel.errorMessage == nil {
                showingAnalysisResults = true
            }
        }
    }
}

// MARK: - Image Picker Integration

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
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
    }
}

// MARK: - Dummy Results View for compilation
// You should create a more detailed view for the actual results.

struct DetailedAnalysisResultsView: View {
    let result: AnalysisResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Top Classifications")) {
                    ForEach(result.classifications.prefix(3)) { classification in
                        VStack(alignment: .leading) {
                            Text(classification.label.capitalized.replacingOccurrences(of: "_", with: " "))
                                .font(.headline)
                            HStack {
                                ProgressView(value: classification.confidence)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                Text("\(Int(classification.confidence * 100))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analysis Results")
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
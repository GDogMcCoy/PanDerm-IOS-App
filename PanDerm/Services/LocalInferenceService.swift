import Foundation
import CoreML
import Vision
import MetalPerformanceShaders
import UIKit
import Accelerate

/// Local inference service for PanDerm model on Apple Intelligence iPhones
/// Handles Core ML model loading, image preprocessing, and multi-task inference
class LocalInferenceService: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isModelLoaded = false
    @Published var modelVersion = "PanDerm_Base_v1.0" // Updated model version
    @Published var inferenceProgress: Double = 0.0
    @Published var currentOperation = "Initializing..."
    @Published var errorMessage: String?
    @Published var performanceMetrics = PerformanceMetrics()
    
    // MARK: - Core ML Components
    
    private var panDermModel: MLModel? // Use generic MLModel instead of auto-generated class
    
    // MARK: - Configuration
    
    // The Vision Transformer model expects a 224x224 image
    private let inputSize = CGSize(width: 224, height: 224)
    private let confidenceThreshold: Float = 0.5
    
    // MARK: - Model Classes
    
    // Based on common dermatology classification tasks
    private let skinConditionClasses = [
        "actinic_keratosis", "basal_cell_carcinoma", "dermatofibroma",
        "melanoma", "nevus", "pigmented_benign_keratosis",
        "seborrheic_keratosis", "squamous_cell_carcinoma", "vascular_lesion"
        // This should be adjusted to match the 15 classes your Python script intended
    ]
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadPanDermModel()
        }
    }
    
    // MARK: - Model Loading
    
    private func loadPanDermModel() async {
        await MainActor.run {
            currentOperation = "Loading PanDerm model..."
            inferenceProgress = 0.0
        }
        
        do {
            guard let modelURL = Bundle.main.url(forResource: "PanDerm", withExtension: "mlpackage") else {
                throw LocalInferenceError.modelNotLoaded
            }
            panDermModel = try MLModel(contentsOf: modelURL, configuration: MLModelConfiguration())
            
            await MainActor.run {
                isModelLoaded = true
                currentOperation = "PanDerm model ready"
                inferenceProgress = 1.0
                errorMessage = nil
            }
            print("✅ PanDerm model loaded successfully")
            
        } catch {
            await MainActor.run {
                currentOperation = "Error loading model"
                inferenceProgress = 0.0
                errorMessage = "Failed to load PanDerm model: \(error.localizedDescription)"
                isModelLoaded = false
            }
            print("❌ Error loading PanDerm model: \(error)")
        }
    }
    
    // MARK: - Image Analysis
    
    /// Analyzes a skin image using the PanDerm model and returns classification results.
    func analyzeImage(_ uiImage: UIImage) async throws -> [ClassificationResult] {
        let startTime = Date()
        
        guard isModelLoaded, let model = panDermModel else {
            throw LocalInferenceError.modelNotLoaded
        }
        
        await MainActor.run {
            currentOperation = "Preprocessing image..."
            inferenceProgress = 0.0
        }
        
        // Preprocess the image for the model
        guard let pixelBuffer = preprocessImage(uiImage) else {
            throw LocalInferenceError.imagePreprocessingFailed
        }
        
        await MainActor.run {
            currentOperation = "Running PanDerm analysis..."
            inferenceProgress = 0.3
        }
        
        // Perform inference
        let output = try await performInference(on: pixelBuffer, model: model)
        
        await MainActor.run {
            currentOperation = "Post-processing results..."
            inferenceProgress = 0.7
        }
        
        // Post-process results
        let classifications = postprocessResults(output, originalImage: uiImage)
        
        // Record performance metrics
        let inferenceTime = Date().timeIntervalSince(startTime)
        await MainActor.run {
            performanceMetrics.recordInference(duration: inferenceTime, mode: .local)
            currentOperation = "Analysis complete"
            inferenceProgress = 1.0
        }
        
        return classifications
    }
    
    private func preprocessImage(_ image: UIImage) -> CVPixelBuffer? {
        let imageSize = self.inputSize
        
        // Resize the image to the target size
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: imageSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        // Convert to CVPixelBuffer
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(resizedImage.size.width),
            Int(resizedImage.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: pixelData,
            width: Int(resizedImage.size.width),
            height: Int(resizedImage.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }
        
        context.translateBy(x: 0, y: resizedImage.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        resizedImage.draw(in: CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return unwrappedPixelBuffer
    }
    
    private func performInference(on pixelBuffer: CVPixelBuffer, model: MLModel) async throws -> MLFeatureProvider {
        do {
            let input = try MLFeatureValue(pixelBuffer: pixelBuffer)
            let inputProvider = try MLDictionaryFeatureProvider(dictionary: ["input": input])
            let output = try await model.prediction(from: inputProvider)
            return output
        } catch {
            throw LocalInferenceError.inferenceFailed(error)
        }
    }
    
    private func postprocessResults(_ output: MLFeatureProvider, originalImage: UIImage) -> [ClassificationResult] {
        // The output name is `linear_48` as seen in the Xcode model inspector.
        guard let multiArray = output.featureValue(for: "linear_48")?.multiArrayValue else {
            return []
        }
        return parseMultiArray(multiArray, originalImage: originalImage)
    }

    private func parseMultiArray(_ multiArray: MLMultiArray, originalImage: UIImage) -> [ClassificationResult] {
        let pointer = try! UnsafeBufferPointer<Float32>(multiArray)
        let probabilities = Array(pointer.prefix(skinConditionClasses.count))
        
        var results: [ClassificationResult] = []
        
        for (label, confidence) in zip(skinConditionClasses, probabilities) {
            let result = ClassificationResult(
                id: UUID(),
                label: label,
                confidence: Double(confidence),
                details: "Confidence score for \(label)"
            )
            results.append(result)
        }
        
        return results.sorted { $0.confidence > $1.confidence }
    }
}

// MARK: - Supporting Types

struct PerformanceMetrics {
    var totalInferences: Int = 0
    var totalDuration: TimeInterval = 0
    var averageDuration: TimeInterval {
        totalInferences > 0 ? totalDuration / Double(totalInferences) : 0
    }
    
    mutating func recordInference(duration: TimeInterval, mode: InferenceMode) {
        totalInferences += 1
        totalDuration += duration
    }
}

enum InferenceMode: String, CaseIterable {
    case automatic = "Automatic"
    case local = "Local"
    case cloud = "Cloud"
    
    var description: String {
        switch self {
        case .automatic:
            return "Automatically choose between local and cloud inference"
        case .local:
            return "Use local model for inference (requires downloaded model)"
        case .cloud:
            return "Use cloud-based inference (requires internet connection)"
        }
    }
}

enum LocalInferenceError: Error {
    case modelNotLoaded
    case imagePreprocessingFailed
    case inferenceFailed(Error)
    case invalidResults
    case resultPostprocessingFailed
}

// MARK: - PanDerm Inference Manager

class PanDermInferenceManager: ObservableObject {
    @Published var inferenceMode: InferenceMode = .automatic
    @Published var localModelStatus: ModelStatus = .notLoaded
    @Published var inferenceProgress: Double = 0.0
    @Published var currentOperation: String = ""
    @Published var modelVersion: String = "v1.0.0"
    @Published var isOnline: Bool = true
    
    private let localInferenceService = LocalInferenceService()
    
    init() {
        // Initialize the manager
        checkModelStatus()
        checkNetworkStatus()
    }
    
    func checkModelStatus() {
        if localInferenceService.isModelLoaded {
            localModelStatus = .loaded
        } else {
            localModelStatus = .notLoaded
        }
    }
    
    func checkNetworkStatus() {
        // Simple network check - in a real app, you'd implement proper network monitoring
        isOnline = true
    }
    
    func clearPerformanceData() {
        localInferenceService.performanceMetrics = PerformanceMetrics()
    }
    
    func getPerformanceStats() -> PerformanceStats {
        let metrics = localInferenceService.performanceMetrics
        return PerformanceStats(
            totalInferences: metrics.totalInferences,
            averageInferenceTime: metrics.averageDuration,
            totalRiskAnalyses: 0,
            averageRiskAnalysisTime: 0,
            totalChangeDetections: 0,
            averageChangeDetectionTime: 0,
            modeUsage: [.local: metrics.totalInferences, .cloud: 0]
        )
    }
}

// MARK: - Supporting Types

enum ModelStatus: String, CaseIterable {
    case notLoaded = "Not Loaded"
    case loading = "Loading"
    case loaded = "Loaded"
    case error = "Error"
}

struct PerformanceStats {
    let totalInferences: Int
    let averageInferenceTime: TimeInterval
    let totalRiskAnalyses: Int
    let averageRiskAnalysisTime: TimeInterval
    let totalChangeDetections: Int
    let averageChangeDetectionTime: TimeInterval
    let modeUsage: [InferenceMode: Int]
}
import Foundation
import CoreML
import Vision
import MetalPerformanceShaders
import UIKit
import Accelerate

/// Local inference service for PanDerm model
/// Handles on-device AI analysis using Core ML and Vision frameworks
@MainActor
class LocalInferenceService: ObservableObject {
    @Published var isModelLoaded = false
    @Published var modelVersion = "PanDerm-Local-v1.0"
    @Published var inferenceProgress: Double = 0.0
    @Published var errorMessage: String?
    
    // Core ML model and Vision requests
    private var panDermModel: MLModel?
    private var classificationRequest: VNCoreMLRequest?
    private var segmentationRequest: VNCoreMLRequest?
    private var objectDetectionRequest: VNCoreMLRequest?
    
    // Metal device for GPU acceleration
    private let metalDevice: MTLDevice?
    private let commandQueue: MTLCommandQueue?
    
    // Model configuration
    private let modelConfig = ModelConfiguration()
    private let inputSize = CGSize(width: 512, height: 512)
    private let confidenceThreshold: Float = 0.5
    
    init() {
        // Initialize Metal device for GPU acceleration
        metalDevice = MTLCreateSystemDefaultDevice()
        commandQueue = metalDevice?.makeCommandQueue()
        
        // Load the PanDerm model
        loadPanDermModel()
    }
    
    // MARK: - Model Loading
    
    private func loadPanDermModel() {
        do {
            // Load the Core ML model
            // Note: In production, this would be the actual PanDerm model file
            // For now, we'll create a placeholder that simulates the model
            isModelLoaded = true
            setupVisionRequests()
        } catch {
            errorMessage = "Failed to load PanDerm model: \(error.localizedDescription)"
            isModelLoaded = false
        }
    }
    
    private func setupVisionRequests() {
        guard isModelLoaded else { return }
        
        // Setup classification request for skin condition classification
        classificationRequest = VNCoreMLRequest { [weak self] request, error in
            self?.handleClassificationResults(request: request, error: error)
        }
        
        // Setup segmentation request for lesion segmentation
        segmentationRequest = VNCoreMLRequest { [weak self] request, error in
            self?.handleSegmentationResults(request: request, error: error)
        }
        
        // Setup object detection request for finding detection
        objectDetectionRequest = VNCoreMLRequest { [weak self] request, error in
            self?.handleDetectionResults(request: request, error: error)
        }
        
        // Configure request properties
        classificationRequest?.imageCropAndScaleOption = .centerCrop
        segmentationRequest?.imageCropAndScaleOption = .centerCrop
        objectDetectionRequest?.imageCropAndScaleOption = .centerCrop
    }
    
    // MARK: - Image Analysis
    
    /// Analyzes a skin image using local PanDerm model
    func analyzeImage(_ image: SkinImage) async throws -> AnalysisResult {
        guard isModelLoaded else {
            throw LocalInferenceError.modelNotLoaded
        }
        
        guard let uiImage = UIImage(data: image.imageData) else {
            throw LocalInferenceError.invalidImageData
        }
        
        inferenceProgress = 0.0
        
        // Perform comprehensive analysis
        let results = try await performComprehensiveAnalysis(image: uiImage, skinImage: image)
        
        inferenceProgress = 1.0
        
        return results
    }
    
    /// Performs comprehensive analysis including classification, segmentation, and detection
    private func performComprehensiveAnalysis(image: UIImage, skinImage: SkinImage) async throws -> AnalysisResult {
        var findings: [Finding] = []
        var recommendations: [Recommendation] = []
        var overallConfidence: Double = 0.0
        
        // 1. Skin Condition Classification
        let classificationResult = try await performClassification(image: image)
        findings.append(contentsOf: classificationResult.findings)
        overallConfidence = max(overallConfidence, classificationResult.confidence)
        
        // 2. Lesion Segmentation
        let segmentationResult = try await performSegmentation(image: image)
        findings.append(contentsOf: segmentationResult.findings)
        overallConfidence = max(overallConfidence, segmentationResult.confidence)
        
        // 3. Object Detection for specific findings
        let detectionResult = try await performObjectDetection(image: image)
        findings.append(contentsOf: detectionResult.findings)
        overallConfidence = max(overallConfidence, detectionResult.confidence)
        
        // 4. Generate recommendations based on findings
        recommendations = generateRecommendations(from: findings, skinImage: skinImage)
        
        return AnalysisResult(
            analysisType: .skinCancerScreening,
            confidence: overallConfidence,
            findings: findings,
            recommendations: recommendations,
            modelVersion: modelVersion
        )
    }
    
    // MARK: - Classification Analysis
    
    private func performClassification(image: UIImage) async throws -> AnalysisResult {
        guard let cgImage = image.cgImage else {
            throw LocalInferenceError.invalidImageData
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // Simulate classification results (replace with actual model inference)
            let findings = simulateClassificationFindings(image: image)
            let confidence = Double.random(in: 0.7...0.95)
            
            let result = AnalysisResult(
                analysisType: .lesionClassification,
                confidence: confidence,
                findings: findings,
                recommendations: [],
                modelVersion: modelVersion
            )
            
            continuation.resume(returning: result)
        }
    }
    
    // MARK: - Segmentation Analysis
    
    private func performSegmentation(image: UIImage) async throws -> AnalysisResult {
        guard let cgImage = image.cgImage else {
            throw LocalInferenceError.invalidImageData
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // Simulate segmentation results (replace with actual model inference)
            let findings = simulateSegmentationFindings(image: image)
            let confidence = Double.random(in: 0.8...0.98)
            
            let result = AnalysisResult(
                analysisType: .segmentation,
                confidence: confidence,
                findings: findings,
                recommendations: [],
                modelVersion: modelVersion
            )
            
            continuation.resume(returning: result)
        }
    }
    
    // MARK: - Object Detection
    
    private func performObjectDetection(image: UIImage) async throws -> AnalysisResult {
        guard let cgImage = image.cgImage else {
            throw LocalInferenceError.invalidImageData
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // Simulate detection results (replace with actual model inference)
            let findings = simulateDetectionFindings(image: image)
            let confidence = Double.random(in: 0.75...0.92)
            
            let result = AnalysisResult(
                analysisType: .skinCancerScreening,
                confidence: confidence,
                findings: findings,
                recommendations: [],
                modelVersion: modelVersion
            )
            
            continuation.resume(returning: result)
        }
    }
    
    // MARK: - Patient Risk Analysis
    
    /// Analyzes patient risk factors using local model
    func analyzePatientRisk(_ patient: Patient) async throws -> PatientRiskAnalysis {
        guard isModelLoaded else {
            throw LocalInferenceError.modelNotLoaded
        }
        
        // Simulate patient risk analysis (replace with actual model inference)
        let riskScore = calculateLocalRiskScore(for: patient)
        let riskLevel = determineRiskLevel(score: riskScore)
        let riskFactors = extractRiskFactors(from: patient)
        let recommendations = generateRiskRecommendations(for: patient)
        
        return PatientRiskAnalysis(
            riskScore: riskScore,
            riskLevel: riskLevel,
            riskFactors: riskFactors,
            recommendations: recommendations,
            confidence: 0.85,
            analysisDate: Date()
        )
    }
    
    // MARK: - Change Detection
    
    /// Detects changes between baseline and current images
    func detectChanges(baselineImages: [SkinImage], currentImages: [SkinImage]) async throws -> ChangeDetectionResult {
        guard isModelLoaded else {
            throw LocalInferenceError.modelNotLoaded
        }
        
        // Simulate change detection (replace with actual model inference)
        let changesDetected = Bool.random()
        let changeScore = Double.random(in: 0.0...1.0)
        let changeDescription = changesDetected ? "Significant changes detected in lesion characteristics" : "No significant changes detected"
        
        return ChangeDetectionResult(
            changesDetected: changesDetected,
            changeScore: changeScore,
            changeDescription: changeDescription,
            confidence: Double.random(in: 0.8...0.95),
            analysisDate: Date()
        )
    }
    
    // MARK: - Image Preprocessing
    
    /// Preprocesses image for model input
    private func preprocessImage(_ image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = Int(inputSize.width)
        let height = Int(inputSize.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return buffer
    }
    
    // MARK: - Result Handlers
    
    private func handleClassificationResults(request: VNRequest, error: Error?) {
        if let error = error {
            errorMessage = "Classification error: \(error.localizedDescription)"
            return
        }
        
        // Process classification results
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        // Convert to findings
        let findings = results.compactMap { observation -> Finding? in
            guard observation.confidence > confidenceThreshold else { return nil }
            
            return Finding(
                description: observation.identifier,
                confidence: Double(observation.confidence),
                category: mapClassificationToCategory(observation.identifier),
                severity: determineSeverity(confidence: observation.confidence),
                location: nil,
                measurements: nil
            )
        }
        
        // Update results
        // This would be handled in the async continuation
    }
    
    private func handleSegmentationResults(request: VNRequest, error: Error?) {
        if let error = error {
            errorMessage = "Segmentation error: \(error.localizedDescription)"
            return
        }
        
        // Process segmentation results
        guard let results = request.results as? [VNPixelBufferObservation] else { return }
        
        // Convert to findings
        let findings = results.compactMap { observation -> Finding? in
            // Process segmentation mask and extract findings
            return nil // Placeholder
        }
    }
    
    private func handleDetectionResults(request: VNRequest, error: Error?) {
        if let error = error {
            errorMessage = "Detection error: \(error.localizedDescription)"
            return
        }
        
        // Process detection results
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        // Convert to findings
        let findings = results.compactMap { observation -> Finding? in
            guard let topLabelObservation = observation.labels.first else { return nil }
            
            return Finding(
                description: topLabelObservation.identifier,
                confidence: Double(topLabelObservation.confidence),
                category: mapDetectionToCategory(topLabelObservation.identifier),
                severity: determineSeverity(confidence: topLabelObservation.confidence),
                location: "Bounding box: \(observation.boundingBox)",
                measurements: nil
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func simulateClassificationFindings(image: UIImage) -> [Finding] {
        let possibleConditions = [
            "Melanoma", "Basal Cell Carcinoma", "Squamous Cell Carcinoma",
            "Benign Nevus", "Actinic Keratosis", "Dermatofibroma",
            "Seborrheic Keratosis", "Hemangioma", "Eczema", "Psoriasis"
        ]
        
        let randomCondition = possibleConditions.randomElement() ?? "Unknown"
        let confidence = Double.random(in: 0.6...0.95)
        
        return [
            Finding(
                description: randomCondition,
                confidence: confidence,
                category: mapClassificationToCategory(randomCondition),
                severity: determineSeverity(confidence: Float(confidence)),
                location: nil,
                measurements: nil
            )
        ]
    }
    
    private func simulateSegmentationFindings(image: UIImage) -> [Finding] {
        let measurements = [
            SkinMeasurement(type: .diameter, value: Double.random(in: 2.0...15.0), unit: "mm"),
            SkinMeasurement(type: .area, value: Double.random(in: 4.0...225.0), unit: "mm²")
        ]
        
        return [
            Finding(
                description: "Segmented lesion with defined borders",
                confidence: Double.random(in: 0.8...0.98),
                category: .suspicious,
                severity: .moderate,
                location: "Center of image",
                measurements: measurements
            )
        ]
    }
    
    private func simulateDetectionFindings(image: UIImage) -> [Finding] {
        let findings = [
            "Asymmetry detected",
            "Irregular border identified",
            "Color variation observed",
            "Diameter exceeds 6mm"
        ]
        
        return findings.map { finding in
            Finding(
                description: finding,
                confidence: Double.random(in: 0.7...0.9),
                category: .suspicious,
                severity: .moderate,
                location: nil,
                measurements: nil
            )
        }
    }
    
    private func generateRecommendations(from findings: [Finding], skinImage: SkinImage) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        let suspiciousFindings = findings.filter { $0.category == .suspicious || $0.category == .malignant }
        
        if !suspiciousFindings.isEmpty {
            recommendations.append(Recommendation(
                action: "Schedule immediate dermatologist consultation",
                priority: .high,
                timeframe: "Within 1 week",
                rationale: "Suspicious findings detected requiring professional evaluation"
            ))
        }
        
        if findings.contains(where: { $0.category == .malignant }) {
            recommendations.append(Recommendation(
                action: "Urgent biopsy recommended",
                priority: .urgent,
                timeframe: "Within 48 hours",
                rationale: "Malignant characteristics detected"
            ))
        }
        
        recommendations.append(Recommendation(
            action: "Monitor for changes over time",
            priority: .medium,
            timeframe: "3-6 months",
            rationale: "Regular monitoring recommended for early detection"
        ))
        
        return recommendations
    }
    
    private func calculateLocalRiskScore(for patient: Patient) -> Int {
        var score = patient.riskFactors.riskScore
        
        // Add local model-specific risk factors
        if patient.age > 50 { score += 2 }
        if patient.gender == .male { score += 1 }
        if patient.medicalHistory.familyHistory.melanoma { score += 3 }
        
        return min(score, 20) // Cap at 20
    }
    
    private func determineRiskLevel(score: Int) -> String {
        switch score {
        case 0...3: return "Low"
        case 4...7: return "Medium"
        case 8...12: return "High"
        default: return "Very High"
        }
    }
    
    private func extractRiskFactors(from patient: Patient) -> [String] {
        var factors: [String] = []
        
        if patient.riskFactors.fairSkin { factors.append("Fair skin") }
        if patient.riskFactors.manyMoles { factors.append("Many moles") }
        if patient.riskFactors.familyHistory { factors.append("Family history") }
        if patient.age > 50 { factors.append("Age > 50") }
        if patient.gender == .male { factors.append("Male gender") }
        
        return factors
    }
    
    private func generateRiskRecommendations(for patient: Patient) -> [String] {
        var recommendations: [String] = []
        
        if patient.riskFactors.fairSkin {
            recommendations.append("Use broad-spectrum sunscreen with SPF 30+ daily")
        }
        if patient.riskFactors.manyMoles {
            recommendations.append("Schedule regular skin cancer screenings")
        }
        if patient.age > 50 {
            recommendations.append("Annual full-body skin examination recommended")
        }
        
        return recommendations
    }
    
    private func mapClassificationToCategory(_ identifier: String) -> FindingCategory {
        let lowercased = identifier.lowercased()
        
        if lowercased.contains("melanoma") || lowercased.contains("carcinoma") {
            return .malignant
        } else if lowercased.contains("suspicious") || lowercased.contains("atypical") {
            return .suspicious
        } else if lowercased.contains("benign") || lowercased.contains("nevus") {
            return .benign
        } else if lowercased.contains("eczema") || lowercased.contains("psoriasis") {
            return .inflammatory
        } else {
            return .other
        }
    }
    
    private func mapDetectionToCategory(_ identifier: String) -> FindingCategory {
        let lowercased = identifier.lowercased()
        
        if lowercased.contains("asymmetry") || lowercased.contains("border") || lowercased.contains("color") {
            return .suspicious
        } else {
            return .other
        }
    }
    
    private func determineSeverity(confidence: Float) -> Severity {
        switch confidence {
        case 0.0..<0.3: return .mild
        case 0.3..<0.7: return .moderate
        case 0.7..<0.9: return .severe
        default: return .critical
        }
    }
}

// MARK: - Model Configuration

struct ModelConfiguration {
    let inputSize = CGSize(width: 512, height: 512)
    let confidenceThreshold: Float = 0.5
    let maxDetections: Int = 10
    let segmentationThreshold: Float = 0.3
}

// MARK: - Errors

enum LocalInferenceError: Error, LocalizedError {
    case modelNotLoaded
    case invalidImageData
    case preprocessingFailed
    case inferenceFailed
    case gpuNotAvailable
    case memoryError
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "PanDerm model not loaded"
        case .invalidImageData:
            return "Invalid image data provided"
        case .preprocessingFailed:
            return "Image preprocessing failed"
        case .inferenceFailed:
            return "Model inference failed"
        case .gpuNotAvailable:
            return "GPU acceleration not available"
        case .memoryError:
            return "Insufficient memory for inference"
        }
    }
} 
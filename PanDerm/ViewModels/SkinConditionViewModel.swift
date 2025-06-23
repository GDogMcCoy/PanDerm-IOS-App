import Foundation
import SwiftUI
import UIKit
import Combine

/// ViewModel for managing skin condition analysis.
@MainActor
class SkinConditionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var analysisResult: AnalysisResult?
    @Published var analysisResults: [AnalysisResult] = []
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var currentOperation = ""
    
    // MARK: - Private Properties
    
    private let analysisService = AnalysisService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAnalysisHistory()
    }
    
    // MARK: - PanDerm AI Analysis
    
    /// Analyzes a single image using the provided inference service.
    ///
    /// - Parameters:
    ///   - image: The UIImage to be analyzed.
    ///   - inferenceService: The `LocalInferenceService` instance to use for analysis.
    func analyzeImage(_ image: UIImage, using inferenceService: LocalInferenceService) async {
        isAnalyzing = true
        errorMessage = nil
        analysisProgress = 0.0
        currentOperation = "Preparing image for analysis..."
        
        do {
            // Convert UIImage to data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw AnalysisError.imageConversionFailed
            }
            
            let skinImage = SkinImage(imageData: imageData)
            
            // Update progress
            analysisProgress = 0.2
            currentOperation = "Running AI analysis..."
            
            // Perform analysis using the inference service
            let classifications = try await inferenceService.analyzeImage(image)
            
            // Update progress
            analysisProgress = 0.8
            currentOperation = "Processing results..."
            
            // Create analysis result
            let result = try await createAnalysisResult(
                from: classifications,
                skinImage: skinImage,
                modelVersion: inferenceService.modelVersion
            )
            
            // Update progress
            analysisProgress = 1.0
            currentOperation = "Analysis complete"
            
            // Store result
            analysisResult = result
            analysisResults.insert(result, at: 0)
            
            // Save to persistent storage
            await saveAnalysisResult(result)
            
            isAnalyzing = false
            
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
            isAnalyzing = false
            analysisProgress = 0.0
            currentOperation = ""
        }
    }
    
    // MARK: - Result Processing
    
    private func createAnalysisResult(
        from classifications: [ClassificationResult],
        skinImage: SkinImage,
        modelVersion: String
    ) async throws -> AnalysisResult {
        
        // Get the top classification
        guard let topClassification = classifications.first else {
            throw AnalysisError.noResultsFound
        }
        
        // Generate findings based on classifications
        let findings = generateFindings(from: classifications)
        
        // Generate recommendations based on findings
        let recommendations = generateRecommendations(from: findings, topClassification: topClassification)
        
        // Determine analysis type based on classification
        let analysisType = determineAnalysisType(from: topClassification)
        
        return AnalysisResult(
            analysisType: analysisType,
            confidence: topClassification.confidence,
            findings: findings,
            recommendations: recommendations,
            modelVersion: modelVersion,
            classifications: classifications
        )
    }
    
    private func generateFindings(from classifications: [ClassificationResult]) -> [Finding] {
        var findings: [Finding] = []
        
        for classification in classifications.prefix(3) {
            let severity = determineSeverity(from: classification)
            let findingType = mapClassificationToFindingType(classification.label)
            
            let finding = Finding(
                type: findingType,
                description: "Detected \(classification.label.replacingOccurrences(of: "_", with: " ")) with \(Int(classification.confidence * 100))% confidence",
                severity: severity,
                confidence: classification.confidence
            )
            
            findings.append(finding)
        }
        
        return findings
    }
    
    private func generateRecommendations(
        from findings: [Finding],
        topClassification: ClassificationResult
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Determine urgency based on classification
        let isMalignant = ["melanoma", "basal_cell_carcinoma", "squamous_cell_carcinoma"].contains(topClassification.label)
        let isHighConfidence = topClassification.confidence > 0.8
        
        if isMalignant && isHighConfidence {
            recommendations.append(Recommendation(
                type: .immediate_consultation,
                priority: .urgent,
                description: "Seek immediate dermatological consultation due to potential malignant findings",
                timeframe: "Within 24-48 hours",
                followUpRequired: true
            ))
            
            recommendations.append(Recommendation(
                type: .biopsy,
                priority: .high,
                description: "Biopsy may be required for definitive diagnosis",
                followUpRequired: true
            ))
        } else if isMalignant {
            recommendations.append(Recommendation(
                type: .routine_checkup,
                priority: .medium,
                description: "Schedule a dermatological consultation for evaluation",
                timeframe: "Within 1-2 weeks",
                followUpRequired: true
            ))
        } else {
            recommendations.append(Recommendation(
                type: .self_monitoring,
                priority: .low,
                description: "Continue self-monitoring. Check for changes in size, color, or texture",
                timeframe: "Monthly self-examination"
            ))
        }
        
        // Add general recommendations
        recommendations.append(Recommendation(
            type: .lifestyle_modification,
            priority: .medium,
            description: "Use broad-spectrum sunscreen daily and avoid excessive sun exposure"
        ))
        
        return recommendations
    }
    
    // MARK: - Helper Methods
    
    private func determineSeverity(from classification: ClassificationResult) -> Severity {
        let malignantConditions = ["melanoma", "basal_cell_carcinoma", "squamous_cell_carcinoma"]
        
        if malignantConditions.contains(classification.label) {
            return classification.confidence > 0.8 ? .critical : .high
        } else if classification.confidence > 0.8 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func mapClassificationToFindingType(_ label: String) -> FindingType {
        switch label.lowercased() {
        case "melanoma", "basal_cell_carcinoma", "squamous_cell_carcinoma":
            return .lesion
        case "nevus", "melanocytic_nevus":
            return .mole
        case "seborrheic_keratosis", "actinic_keratosis":
            return .lesion
        case "dermatofibroma":
            return .lesion
        default:
            return .lesion
        }
    }
    
    private func determineAnalysisType(from classification: ClassificationResult) -> AnalysisType {
        let malignantConditions = ["melanoma", "basal_cell_carcinoma", "squamous_cell_carcinoma"]
        
        if malignantConditions.contains(classification.label) {
            return .skinCancerScreening
        } else if classification.label.contains("nevus") {
            return .moleMonitoring
        } else {
            return .skinConditionDiagnosis
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveAnalysisResult(_ result: AnalysisResult) async {
        do {
            try await analysisService.saveAnalysisResult(result)
        } catch {
            print("Failed to save analysis result: \(error)")
        }
    }
    
    private func loadAnalysisHistory() {
        Task {
            do {
                analysisResults = try await analysisService.loadAnalysisResults()
            } catch {
                print("Failed to load analysis history: \(error)")
            }
        }
    }
    
    // MARK: - Result Management
    
    func clearResults() {
        analysisResult = nil
        analysisResults.removeAll()
    }
    
    func deleteResult(_ result: AnalysisResult) {
        analysisResults.removeAll { $0.id == result.id }
        
        Task {
            do {
                try await analysisService.deleteAnalysisResult(result.id)
            } catch {
                print("Failed to delete analysis result: \(error)")
            }
        }
    }
    
    // MARK: - Statistics
    
    var totalAnalyses: Int {
        analysisResults.count
    }
    
    var highRiskAnalyses: Int {
        analysisResults.filter { result in
            result.findings.contains { $0.severity == .high || $0.severity == .critical }
        }.count
    }
    
    var averageConfidence: Double {
        guard !analysisResults.isEmpty else { return 0 }
        let totalConfidence = analysisResults.reduce(0) { $0 + $1.confidence }
        return totalConfidence / Double(analysisResults.count)
    }
}

// MARK: - Analysis Service

class AnalysisService {
    private let storageKey = "panderm_analysis_results"
    
    func saveAnalysisResult(_ result: AnalysisResult) async throws {
        var results = try await loadAnalysisResults()
        results.insert(result, at: 0) // Insert at beginning for chronological order
        
        // Keep only the last 100 results to manage storage
        if results.count > 100 {
            results = Array(results.prefix(100))
        }
        
        try await saveAnalysisResults(results)
    }
    
    func loadAnalysisResults() async throws -> [AnalysisResult] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        return try JSONDecoder().decode([AnalysisResult].self, from: data)
    }
    
    func deleteAnalysisResult(_ resultId: UUID) async throws {
        var results = try await loadAnalysisResults()
        results.removeAll { $0.id == resultId }
        try await saveAnalysisResults(results)
    }
    
    private func saveAnalysisResults(_ results: [AnalysisResult]) async throws {
        let data = try JSONEncoder().encode(results)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

// MARK: - Analysis Error

enum AnalysisError: Error, LocalizedError {
    case imageConversionFailed
    case noResultsFound
    case analysisTimeout
    case invalidImageFormat
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image for analysis"
        case .noResultsFound:
            return "No analysis results found"
        case .analysisTimeout:
            return "Analysis timed out"
        case .invalidImageFormat:
            return "Invalid image format"
        }
    }
} 
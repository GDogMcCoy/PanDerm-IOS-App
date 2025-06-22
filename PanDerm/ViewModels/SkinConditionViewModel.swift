import Foundation
import SwiftUI
import UIKit

/// ViewModel for managing skin condition analysis and PanDerm AI integration
/// Handles image capture, analysis, and results management with local inference support
@MainActor
class SkinConditionViewModel: ObservableObject {
    @Published var skinConditions: [SkinCondition] = []
    @Published var selectedCondition: SkinCondition?
    @Published var capturedImages: [SkinImage] = []
    @Published var analysisResults: [AnalysisResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var analysisProgress: Double = 0.0
    
    // Inference manager for local/cloud analysis
    @StateObject private var inferenceManager = PanDermInferenceManager()
    
    // MARK: - Image Management
    
    func addImage(_ image: UIImage, type: ImageType, bodyLocation: BodyLocation) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            return
        }
        
        let skinImage = SkinImage(
            imageData: imageData,
            imageType: type,
            bodyLocation: bodyLocation
        )
        
        capturedImages.append(skinImage)
    }
    
    func removeImage(_ image: SkinImage) {
        capturedImages.removeAll { $0.id == image.id }
    }
    
    func clearImages() {
        capturedImages.removeAll()
    }
    
    // MARK: - Skin Condition Management
    
    func createSkinCondition(
        name: String,
        category: SkinConditionCategory,
        severity: Severity,
        bodyLocation: BodyLocation,
        symptoms: [Symptom] = [],
        notes: String = ""
    ) {
        let condition = SkinCondition(
            name: name,
            category: category,
            severity: severity,
            bodyLocation: bodyLocation,
            symptoms: symptoms,
            images: capturedImages,
            notes: notes
        )
        
        skinConditions.append(condition)
        selectedCondition = condition
        clearImages()
        saveSkinConditions()
    }
    
    func updateSkinCondition(_ condition: SkinCondition) {
        if let index = skinConditions.firstIndex(where: { $0.id == condition.id }) {
            skinConditions[index] = condition
            saveSkinConditions()
        }
    }
    
    func deleteSkinCondition(_ condition: SkinCondition) {
        skinConditions.removeAll { $0.id == condition.id }
        saveSkinConditions()
    }
    
    func selectCondition(_ condition: SkinCondition) {
        selectedCondition = condition
        capturedImages = condition.images
        analysisResults = condition.analysisResults
    }
    
    // MARK: - PanDerm AI Analysis with Local Inference
    
    func analyzeImages() async {
        guard !capturedImages.isEmpty else {
            errorMessage = "No images to analyze"
            return
        }
        
        isLoading = true
        errorMessage = nil
        analysisProgress = 0.0
        
        do {
            // Use inference manager for intelligent routing
            let results = try await inferenceManager.analyzeMultipleImages(capturedImages)
            analysisResults = results
            
            // Update the images with analysis results
            for (index, result) in results.enumerated() {
                if index < capturedImages.count {
                    capturedImages[index].analysisResults.append(result)
                }
            }
            
            // Update selected condition if exists
            if let condition = selectedCondition {
                var updatedCondition = condition
                updatedCondition.images = capturedImages
                updatedCondition.analysisResults = analysisResults
                updateSkinCondition(updatedCondition)
            }
            
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func analyzeSpecificImage(_ image: SkinImage) async -> AnalysisResult? {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await inferenceManager.analyzeImage(image)
            analysisResults.append(result)
            return result
        } catch {
            errorMessage = "Image analysis failed: \(error.localizedDescription)"
            return nil
        } finally {
            isLoading = false
        }
    }
    
    // MARK: - Change Detection with Local Inference
    
    func detectChanges(baselineImages: [SkinImage], currentImages: [SkinImage]) async -> ChangeDetectionResult? {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await inferenceManager.detectChanges(baselineImages: baselineImages, currentImages: currentImages)
            return result
        } catch {
            errorMessage = "Change detection failed: \(error.localizedDescription)"
            return nil
        } finally {
            isLoading = false
        }
    }
    
    // MARK: - Analysis Results Processing
    
    func getOverallRiskLevel() -> String {
        guard !analysisResults.isEmpty else { return "Unknown" }
        
        let suspiciousFindings = analysisResults.flatMap { $0.findings }
            .filter { $0.category == .suspicious || $0.category == .malignant }
        
        if suspiciousFindings.contains(where: { $0.confidence > 0.8 }) {
            return "High"
        } else if suspiciousFindings.contains(where: { $0.confidence > 0.6 }) {
            return "Medium"
        } else {
            return "Low"
        }
    }
    
    func getCriticalFindings() -> [Finding] {
        return analysisResults.flatMap { $0.findings }
            .filter { $0.category == .malignant && $0.confidence > 0.7 }
    }
    
    func getRecommendations() -> [Recommendation] {
        return analysisResults.flatMap { $0.recommendations }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    func generateAnalysisReport() -> SkinConditionReport {
        guard let condition = selectedCondition else {
            return SkinConditionReport(
                condition: SkinCondition(id: UUID(), name: "", category: .other, bodyLocation: .other),
                overallRisk: "Unknown",
                criticalFindings: [],
                recommendations: [],
                analysisDate: Date()
            )
        }
        
        return SkinConditionReport(
            condition: condition,
            overallRisk: getOverallRiskLevel(),
            criticalFindings: getCriticalFindings(),
            recommendations: getRecommendations(),
            analysisDate: Date()
        )
    }
    
    // MARK: - Inference Status
    
    var inferenceStatus: String {
        if inferenceManager.isLoading {
            return "\(inferenceManager.currentOperation) (\(Int(inferenceManager.inferenceProgress * 100))%)"
        } else {
            return "Ready"
        }
    }
    
    var inferenceMode: String {
        return inferenceManager.inferenceMode.rawValue
    }
    
    var isLocalModelAvailable: Bool {
        return inferenceManager.localModelStatus == .loaded
    }
    
    var isOnline: Bool {
        return inferenceManager.isOnline
    }
    
    // MARK: - Symptom Management
    
    func addSymptom(name: String, severity: Symptom.SymptomSeverity, duration: String? = nil, notes: String? = nil) {
        let symptom = Symptom(
            name: name,
            severity: severity,
            duration: duration,
            notes: notes
        )
        
        // Add to current condition if selected
        if var condition = selectedCondition {
            condition.symptoms.append(symptom)
            updateSkinCondition(condition)
        }
    }
    
    func removeSymptom(_ symptom: Symptom) {
        if var condition = selectedCondition {
            condition.symptoms.removeAll { $0.id == symptom.id }
            updateSkinCondition(condition)
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveSkinConditions() {
        if let encoded = try? JSONEncoder().encode(skinConditions) {
            UserDefaults.standard.set(encoded, forKey: "savedSkinConditions")
        }
    }
    
    func loadSkinConditions() {
        if let data = UserDefaults.standard.data(forKey: "savedSkinConditions"),
           let decoded = try? JSONDecoder().decode([SkinCondition].self, from: data) {
            skinConditions = decoded
        }
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        let sampleConditions = [
            SkinCondition(
                name: "Suspicious mole on left arm",
                category: .neoplastic,
                severity: .moderate,
                bodyLocation: .arms,
                symptoms: [
                    Symptom(name: "Itching", severity: .mild),
                    Symptom(name: "Color change", severity: .moderate)
                ],
                notes: "Patient noticed color change in existing mole"
            ),
            SkinCondition(
                name: "Eczema flare-up",
                category: .inflammatory,
                severity: .moderate,
                bodyLocation: .hands,
                symptoms: [
                    Symptom(name: "Redness", severity: .moderate),
                    Symptom(name: "Dryness", severity: .severe),
                    Symptom(name: "Itching", severity: .moderate)
                ],
                notes: "Recurring condition, worse in winter"
            )
        ]
        
        skinConditions = sampleConditions
        saveSkinConditions()
    }
    
    // MARK: - Utility Methods
    
    func getImageCount(for condition: SkinCondition) -> Int {
        return condition.images.count
    }
    
    func getAnalysisCount(for condition: SkinCondition) -> Int {
        return condition.analysisResults.count
    }
    
    func getLatestAnalysis(for condition: SkinCondition) -> AnalysisResult? {
        return condition.analysisResults.max(by: { $0.analysisDate < $1.analysisDate })
    }
    
    // MARK: - Performance Monitoring
    
    func getPerformanceStats() -> PerformanceStats {
        return inferenceManager.getPerformanceStats()
    }
    
    func clearPerformanceData() {
        inferenceManager.clearPerformanceData()
    }
}

// MARK: - Supporting Types

struct SkinConditionReport {
    let condition: SkinCondition
    let overallRisk: String
    let criticalFindings: [Finding]
    let recommendations: [Recommendation]
    let analysisDate: Date
} 
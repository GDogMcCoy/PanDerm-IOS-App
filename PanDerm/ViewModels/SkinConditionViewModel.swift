import Foundation
import SwiftUI
import UIKit

/// ViewModel for managing skin condition analysis.
@MainActor
class SkinConditionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var analysisResult: AnalysisResult?
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    
    // MARK: - PanDerm AI Analysis
    
    /// Analyzes a single image using the provided inference service.
    ///
    /// - Parameters:
    ///   - image: The UIImage to be analyzed.
    ///   - service: The `LocalInferenceService` instance to use for analysis.
    func analyzeImage(_ image: UIImage, using service: LocalInferenceService) async {
        isAnalyzing = true
        errorMessage = nil
        analysisResult = nil
        
        do {
            // Perform analysis using the service, which now returns [ClassificationResult]
            let classifications = try await service.analyzeImage(image)
            
            // Update state on the main thread, constructing the AnalysisResult here.
            self.analysisResult = AnalysisResult(
                classifications: classifications,
                segmentationMask: nil, // No segmentation in this model
                detectedObjects: []    // No detection in this model
            )
            
        } catch {
            // Handle and publish any errors
            self.errorMessage = "Analysis failed: \(error.localizedDescription)"
            print("❌ Analysis Error: \(error)")
        }
        
        isAnalyzing = false
    }
} 
import Foundation
import UIKit

/// Service for integrating with the PanDerm foundation model
/// Handles API communication and AI analysis requests
class PanDermService: ObservableObject {
    private let baseURL = "https://api.panderm.ai/v1" // Replace with actual API endpoint
    private let apiKey: String
    
    @Published var isConnected = false
    @Published var modelVersion = "PanDerm-v1.0"
    
    init(apiKey: String = "") {
        self.apiKey = apiKey
        // In production, this would be loaded from secure storage
    }
    
    // MARK: - Image Analysis
    
    /// Analyzes a skin image using the PanDerm foundation model
    func analyzeImage(_ image: SkinImage) async throws -> AnalysisResult {
        let endpoint = "\(baseURL)/analyze/image"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Prepare request body
        let requestBody = PanDermImageRequest(
            imageData: image.imageData.base64EncodedString(),
            imageType: image.imageType.rawValue,
            bodyLocation: image.bodyLocation.rawValue,
            magnification: image.magnification?.rawValue,
            lighting: image.lighting?.rawValue,
            modelVersion: modelVersion
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PanDermError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PanDermError.apiError(httpResponse.statusCode)
        }
        
        let analysisResponse = try JSONDecoder().decode(PanDermImageResponse.self, from: data)
        return analysisResponse.toAnalysisResult()
    }
    
    /// Analyzes multiple images for comprehensive assessment
    func analyzeMultipleImages(_ images: [SkinImage]) async throws -> [AnalysisResult] {
        let endpoint = "\(baseURL)/analyze/batch"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = PanDermBatchRequest(
            images: images.map { image in
                PanDermImageRequest(
                    imageData: image.imageData.base64EncodedString(),
                    imageType: image.imageType.rawValue,
                    bodyLocation: image.bodyLocation.rawValue,
                    magnification: image.magnification?.rawValue,
                    lighting: image.lighting?.rawValue,
                    modelVersion: modelVersion
                )
            },
            modelVersion: modelVersion
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PanDermError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PanDermError.apiError(httpResponse.statusCode)
        }
        
        let batchResponse = try JSONDecoder().decode(PanDermBatchResponse.self, from: data)
        return batchResponse.results.map { $0.toAnalysisResult() }
    }
    
    // MARK: - Patient Risk Analysis
    
    /// Analyzes patient risk factors using PanDerm's comprehensive model
    func analyzePatientRisk(_ patient: Patient) async throws -> PatientRiskAnalysis {
        let endpoint = "\(baseURL)/analyze/patient-risk"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = PanDermPatientRequest(
            patient: patient,
            modelVersion: modelVersion
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PanDermError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PanDermError.apiError(httpResponse.statusCode)
        }
        
        let riskResponse = try JSONDecoder().decode(PanDermRiskResponse.self, from: data)
        return riskResponse.toPatientRiskAnalysis()
    }
    
    // MARK: - Change Detection
    
    /// Detects changes in skin conditions over time
    func detectChanges(baselineImages: [SkinImage], currentImages: [SkinImage]) async throws -> ChangeDetectionResult {
        let endpoint = "\(baseURL)/analyze/change-detection"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = PanDermChangeDetectionRequest(
            baselineImages: baselineImages.map { $0.imageData.base64EncodedString() },
            currentImages: currentImages.map { $0.imageData.base64EncodedString() },
            modelVersion: modelVersion
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PanDermError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PanDermError.apiError(httpResponse.statusCode)
        }
        
        let changeResponse = try JSONDecoder().decode(PanDermChangeDetectionResponse.self, from: data)
        return changeResponse.toChangeDetectionResult()
    }
    
    // MARK: - Model Information
    
    /// Gets information about available PanDerm models
    func getModelInfo() async throws -> ModelInfo {
        let endpoint = "\(baseURL)/models/info"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PanDermError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PanDermError.apiError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(ModelInfo.self, from: data)
    }
    
    // MARK: - Connection Test
    
    /// Tests connection to PanDerm API
    func testConnection() async throws -> Bool {
        let endpoint = "\(baseURL)/health"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PanDermError.invalidResponse
        }
        
        isConnected = httpResponse.statusCode == 200
        return isConnected
    }
}

// MARK: - Request/Response Models

struct PanDermImageRequest: Codable {
    let imageData: String // Base64 encoded
    let imageType: String
    let bodyLocation: String
    let magnification: String?
    let lighting: String?
    let modelVersion: String
}

struct PanDermBatchRequest: Codable {
    let images: [PanDermImageRequest]
    let modelVersion: String
}

struct PanDermPatientRequest: Codable {
    let patient: Patient
    let modelVersion: String
}

struct PanDermChangeDetectionRequest: Codable {
    let baselineImages: [String] // Base64 encoded
    let currentImages: [String] // Base64 encoded
    let modelVersion: String
}

struct PanDermImageResponse: Codable {
    let analysisId: String
    let confidence: Double
    let findings: [PanDermFinding]
    let recommendations: [PanDermRecommendation]
    let modelVersion: String
    let processingTime: Double
    
    func toAnalysisResult() -> AnalysisResult {
        return AnalysisResult(
            analysisType: .skinCancerScreening,
            confidence: confidence,
            findings: findings.map { $0.toFinding() },
            recommendations: recommendations.map { $0.toRecommendation() },
            modelVersion: modelVersion
        )
    }
}

struct PanDermBatchResponse: Codable {
    let batchId: String
    let results: [PanDermImageResponse]
    let processingTime: Double
}

struct PanDermRiskResponse: Codable {
    let riskScore: Int
    let riskLevel: String
    let riskFactors: [String]
    let recommendations: [String]
    let confidence: Double
    
    func toPatientRiskAnalysis() -> PatientRiskAnalysis {
        return PatientRiskAnalysis(
            riskScore: riskScore,
            riskLevel: riskLevel,
            riskFactors: riskFactors,
            recommendations: recommendations,
            confidence: confidence,
            analysisDate: Date()
        )
    }
}

struct PanDermChangeDetectionResponse: Codable {
    let changesDetected: Bool
    let changeScore: Double
    let changeDescription: String
    let confidence: Double
    
    func toChangeDetectionResult() -> ChangeDetectionResult {
        return ChangeDetectionResult(
            changesDetected: changesDetected,
            changeScore: changeScore,
            changeDescription: changeDescription,
            confidence: confidence,
            analysisDate: Date()
        )
    }
}

struct PanDermFinding: Codable {
    let description: String
    let confidence: Double
    let category: String
    let severity: String?
    let location: String?
    let measurements: [PanDermMeasurement]?
    
    func toFinding() -> Finding {
        return Finding(
            description: description,
            confidence: confidence,
            category: FindingCategory(rawValue: category) ?? .other,
            severity: Severity(rawValue: severity ?? ""),
            location: location,
            measurements: measurements?.map { $0.toSkinMeasurement() }
        )
    }
}

struct PanDermRecommendation: Codable {
    let action: String
    let priority: String
    let timeframe: String?
    let rationale: String?
    
    func toRecommendation() -> Recommendation {
        return Recommendation(
            action: action,
            priority: Recommendation.Priority(rawValue: priority) ?? .medium,
            timeframe: timeframe,
            rationale: rationale
        )
    }
}

struct PanDermMeasurement: Codable {
    let type: String
    let value: Double
    let unit: String
    
    func toSkinMeasurement() -> SkinMeasurement {
        return SkinMeasurement(
            type: SkinMeasurement.MeasurementType(rawValue: type) ?? .diameter,
            value: value,
            unit: unit
        )
    }
}

struct ModelInfo: Codable {
    let version: String
    let capabilities: [String]
    let lastUpdated: Date
    let performance: ModelPerformance
}

struct ModelPerformance: Codable {
    let accuracy: Double
    let sensitivity: Double
    let specificity: Double
    let auc: Double
}

// MARK: - Supporting Types

struct PatientRiskAnalysis {
    let riskScore: Int
    let riskLevel: String
    let riskFactors: [String]
    let recommendations: [String]
    let confidence: Double
    let analysisDate: Date
}

struct ChangeDetectionResult {
    let changesDetected: Bool
    let changeScore: Double
    let changeDescription: String
    let confidence: Double
    let analysisDate: Date
}

// MARK: - Errors

enum PanDermError: Error, LocalizedError {
    case invalidResponse
    case apiError(Int)
    case invalidImageData
    case networkError
    case authenticationError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from PanDerm API"
        case .apiError(let code):
            return "PanDerm API error: \(code)"
        case .invalidImageData:
            return "Invalid image data provided"
        case .networkError:
            return "Network connection error"
        case .authenticationError:
            return "Authentication failed"
        }
    }
} 
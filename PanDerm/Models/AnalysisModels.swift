import Foundation
import CoreGraphics

// MARK: - Analysis Result Structures

/// The main result container from an inference operation.
struct AnalysisResult {
    let classifications: [ClassificationResult]
    let segmentationMask: CGImage?
    let detectedObjects: [DetectedObject]

    init(classifications: [ClassificationResult], segmentationMask: CGImage?, detectedObjects: [DetectedObject]) {
        self.classifications = classifications
        self.segmentationMask = segmentationMask
        self.detectedObjects = detectedObjects
    }
}

/// Represents a single classification with its confidence score.
struct ClassificationResult: Identifiable {
    let id: UUID
    let label: String
    let confidence: Double
    let details: String

    init(id: UUID = UUID(), label: String, confidence: Double, details: String) {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.details = details
    }
}

/// Represents a single detected object with its bounding box and label.
struct DetectedObject {
    let boundingBox: CGRect
    let label: String
    let confidence: Double
}

// MARK: - Core Image Struct

/// Represents a captured image and its metadata, conforming to Codable for persistence.
struct SkinImage: Identifiable, Codable {
    let id: UUID
    var imageData: Data
    var captureDate: Date

    init(id: UUID = UUID(), imageData: Data, captureDate: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.captureDate = captureDate
    }
} 
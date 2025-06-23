import Foundation
import CoreGraphics
import UIKit

// MARK: - Analysis Result Structures

/// The main result container from an inference operation.
struct AnalysisResult: Identifiable, Codable {
    let id: UUID
    let analysisType: AnalysisType
    let confidence: Double
    let findings: [Finding]
    let recommendations: [Recommendation]
    let modelVersion: String
    let createdAt: Date
    let classifications: [ClassificationResult]
    let segmentationMask: CGImage?
    let detectedObjects: [DetectedObject]

    init(
        id: UUID = UUID(),
        analysisType: AnalysisType,
        confidence: Double,
        findings: [Finding] = [],
        recommendations: [Recommendation] = [],
        modelVersion: String,
        createdAt: Date = Date(),
        classifications: [ClassificationResult] = [],
        segmentationMask: CGImage? = nil,
        detectedObjects: [DetectedObject] = []
    ) {
        self.id = id
        self.analysisType = analysisType
        self.confidence = confidence
        self.findings = findings
        self.recommendations = recommendations
        self.modelVersion = modelVersion
        self.createdAt = createdAt
        self.classifications = classifications
        self.segmentationMask = segmentationMask
        self.detectedObjects = detectedObjects
    }
}

/// Represents a single classification with its confidence score.
struct ClassificationResult: Identifiable, Codable {
    let id: UUID
    let label: String
    let confidence: Double
    let details: String

    init(id: UUID = UUID(), label: String, confidence: Double, details: String = "") {
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
    let imageData: Data
    let captureDate: Date
    let location: BodyLocation?
    let metadata: ImageMetadata?

    init(
        id: UUID = UUID(),
        imageData: Data,
        captureDate: Date = Date(),
        location: BodyLocation? = nil,
        metadata: ImageMetadata? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.captureDate = captureDate
        self.location = location
        self.metadata = metadata
    }
}

// MARK: - Image Metadata
struct ImageMetadata: Codable {
    let cameraModel: String?
    let resolution: CGSize
    let lighting: LightingCondition?
    let distance: Double? // in centimeters
    let angle: Double? // in degrees
    let flash: Bool
    
    enum LightingCondition: String, CaseIterable, Codable {
        case natural = "natural"
        case artificial = "artificial"
        case mixed = "mixed"
        case poor = "poor"
    }
}

// MARK: - Analysis Record (for history)
struct AnalysisRecord: Identifiable, Codable {
    let id: UUID
    let patientId: UUID?
    let patientName: String?
    let imageURL: URL?
    let thumbnailURL: URL?
    let primaryDiagnosis: String
    let confidence: Double
    let riskLevel: RiskLevel
    let createdAt: Date
    let isFlagged: Bool
    let hasFollowUp: Bool
    let recommendations: [String]
    let notes: String?
    
    init(
        id: UUID = UUID(),
        patientId: UUID? = nil,
        patientName: String? = nil,
        imageURL: URL? = nil,
        thumbnailURL: URL? = nil,
        primaryDiagnosis: String,
        confidence: Double,
        riskLevel: RiskLevel,
        createdAt: Date = Date(),
        isFlagged: Bool = false,
        hasFollowUp: Bool = false,
        recommendations: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.patientId = patientId
        self.patientName = patientName
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.primaryDiagnosis = primaryDiagnosis
        self.confidence = confidence
        self.riskLevel = riskLevel
        self.createdAt = createdAt
        self.isFlagged = isFlagged
        self.hasFollowUp = hasFollowUp
        self.recommendations = recommendations
        self.notes = notes
    }
}

// MARK: - Risk Level
enum RiskLevel: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low Risk"
        case .medium:
            return "Medium Risk"
        case .high:
            return "High Risk"
        case .critical:
            return "Critical Risk"
        }
    }
}

// MARK: - Analysis Filter
enum AnalysisFilter: String, CaseIterable {
    case all = "all"
    case highRisk = "high_risk"
    case recent = "recent"
    case flagged = "flagged"
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .highRisk:
            return "High Risk"
        case .recent:
            return "Recent"
        case .flagged:
            return "Flagged"
        }
    }
}

// MARK: - Analysis Type
enum AnalysisType: String, CaseIterable, Codable {
    case skinCancerScreening = "skin_cancer_screening"
    case moleMonitoring = "mole_monitoring"
    case skinConditionDiagnosis = "skin_condition_diagnosis"
    case riskAssessment = "risk_assessment"
    case changeDetection = "change_detection"
    
    var displayName: String {
        switch self {
        case .skinCancerScreening:
            return "Skin Cancer Screening"
        case .moleMonitoring:
            return "Mole Monitoring"
        case .skinConditionDiagnosis:
            return "Skin Condition Diagnosis"
        case .riskAssessment:
            return "Risk Assessment"
        case .changeDetection:
            return "Change Detection"
        }
    }
}

// MARK: - Finding
struct Finding: Identifiable, Codable {
    let id: UUID
    let type: FindingType
    let description: String
    let severity: Severity
    let confidence: Double
    let location: BodyLocation?
    let measurements: Measurements?
    let characteristics: [String]
    
    init(
        id: UUID = UUID(),
        type: FindingType,
        description: String,
        severity: Severity,
        confidence: Double,
        location: BodyLocation? = nil,
        measurements: Measurements? = nil,
        characteristics: [String] = []
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.severity = severity
        self.confidence = confidence
        self.location = location
        self.measurements = measurements
        self.characteristics = characteristics
    }
}

// MARK: - Finding Type
enum FindingType: String, CaseIterable, Codable {
    case lesion = "lesion"
    case mole = "mole"
    case rash = "rash"
    case discoloration = "discoloration"
    case texture_change = "texture_change"
    case asymmetry = "asymmetry"
    case border_irregularity = "border_irregularity"
    case color_variation = "color_variation"
    case diameter_change = "diameter_change"
    case evolution = "evolution"
    
    var displayName: String {
        switch self {
        case .lesion:
            return "Lesion"
        case .mole:
            return "Mole"
        case .rash:
            return "Rash"
        case .discoloration:
            return "Discoloration"
        case .texture_change:
            return "Texture Change"
        case .asymmetry:
            return "Asymmetry"
        case .border_irregularity:
            return "Border Irregularity"
        case .color_variation:
            return "Color Variation"
        case .diameter_change:
            return "Diameter Change"
        case .evolution:
            return "Evolution"
        }
    }
}

// MARK: - Severity
enum Severity: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        case .critical:
            return "purple"
        }
    }
}

// MARK: - Body Location
enum BodyLocation: String, CaseIterable, Codable {
    case head = "head"
    case face = "face"
    case neck = "neck"
    case chest = "chest"
    case back = "back"
    case arms = "arms"
    case hands = "hands"
    case abdomen = "abdomen"
    case legs = "legs"
    case feet = "feet"
    case genital = "genital"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .head:
            return "Head"
        case .face:
            return "Face"
        case .neck:
            return "Neck"
        case .chest:
            return "Chest"
        case .back:
            return "Back"
        case .arms:
            return "Arms"
        case .hands:
            return "Hands"
        case .abdomen:
            return "Abdomen"
        case .legs:
            return "Legs"
        case .feet:
            return "Feet"
        case .genital:
            return "Genital"
        case .other:
            return "Other"
        }
    }
}

// MARK: - Measurements
struct Measurements: Codable {
    let diameter: Double? // in millimeters
    let area: Double? // in square millimeters
    let perimeter: Double? // in millimeters
    let asymmetryScore: Double? // 0.0 to 1.0
    let borderIrregularityScore: Double? // 0.0 to 1.0
    let colorVariationScore: Double? // 0.0 to 1.0
}

// MARK: - Recommendation
struct Recommendation: Identifiable, Codable {
    let id: UUID
    let type: RecommendationType
    let priority: Priority
    let description: String
    let timeframe: String?
    let followUpRequired: Bool
    
    init(
        id: UUID = UUID(),
        type: RecommendationType,
        priority: Priority,
        description: String,
        timeframe: String? = nil,
        followUpRequired: Bool = false
    ) {
        self.id = id
        self.type = type
        self.priority = priority
        self.description = description
        self.timeframe = timeframe
        self.followUpRequired = followUpRequired
    }
}

// MARK: - Recommendation Type
enum RecommendationType: String, CaseIterable, Codable {
    case immediate_consultation = "immediate_consultation"
    case routine_checkup = "routine_checkup"
    case self_monitoring = "self_monitoring"
    case lifestyle_modification = "lifestyle_modification"
    case follow_up_imaging = "follow_up_imaging"
    case biopsy = "biopsy"
    case treatment = "treatment"
    case no_action = "no_action"
    
    var displayName: String {
        switch self {
        case .immediate_consultation:
            return "Immediate Consultation"
        case .routine_checkup:
            return "Routine Checkup"
        case .self_monitoring:
            return "Self Monitoring"
        case .lifestyle_modification:
            return "Lifestyle Modification"
        case .follow_up_imaging:
            return "Follow-up Imaging"
        case .biopsy:
            return "Biopsy"
        case .treatment:
            return "Treatment"
        case .no_action:
            return "No Action Required"
        }
    }
}

// MARK: - Priority
enum Priority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }
} 
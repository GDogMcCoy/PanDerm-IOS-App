import Foundation

/// Represents a skin condition or lesion in the PanDerm system
/// This model stores comprehensive information about skin conditions for analysis
struct SkinCondition: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: SkinConditionCategory
    var severity: Severity
    var bodyLocation: BodyLocation
    var symptoms: [Symptom]
    var images: [SkinImage]
    var analysisResults: [AnalysisResult]
    var diagnosis: Diagnosis?
    var treatmentPlan: TreatmentPlan?
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        category: SkinConditionCategory,
        severity: Severity = .mild,
        bodyLocation: BodyLocation,
        symptoms: [Symptom] = [],
        images: [SkinImage] = [],
        analysisResults: [AnalysisResult] = [],
        diagnosis: Diagnosis? = nil,
        treatmentPlan: TreatmentPlan? = nil,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.severity = severity
        self.bodyLocation = bodyLocation
        self.symptoms = symptoms
        self.images = images
        self.analysisResults = analysisResults
        self.diagnosis = diagnosis
        self.treatmentPlan = treatmentPlan
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Supporting Types

enum SkinConditionCategory: String, CaseIterable, Codable {
    case neoplastic = "neoplastic"
    case inflammatory = "inflammatory"
    case infectious = "infectious"
    case autoimmune = "autoimmune"
    case congenital = "congenital"
    case traumatic = "traumatic"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .neoplastic: return "Neoplastic"
        case .inflammatory: return "Inflammatory"
        case .infectious: return "Infectious"
        case .autoimmune: return "Autoimmune"
        case .congenital: return "Congenital"
        case .traumatic: return "Traumatic"
        case .other: return "Other"
        }
    }
}

enum Severity: String, CaseIterable, Codable {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        case .critical: return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .mild: return "green"
        case .moderate: return "yellow"
        case .severe: return "orange"
        case .critical: return "red"
        }
    }
}

enum BodyLocation: String, CaseIterable, Codable {
    case head = "head"
    case face = "face"
    case neck = "neck"
    case chest = "chest"
    case back = "back"
    case abdomen = "abdomen"
    case arms = "arms"
    case hands = "hands"
    case legs = "legs"
    case feet = "feet"
    case genitals = "genitals"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .head: return "Head"
        case .face: return "Face"
        case .neck: return "Neck"
        case .chest: return "Chest"
        case .back: return "Back"
        case .abdomen: return "Abdomen"
        case .arms: return "Arms"
        case .hands: return "Hands"
        case .legs: return "Legs"
        case .feet: return "Feet"
        case .genitals: return "Genitals"
        case .other: return "Other"
        }
    }
}

struct Symptom: Identifiable, Codable {
    var id: UUID
    var name: String
    var severity: SymptomSeverity
    var duration: String?
    var notes: String?
    
    init(id: UUID = UUID(), name: String, severity: SymptomSeverity, duration: String? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.severity = severity
        self.duration = duration
        self.notes = notes
    }
    
    enum SymptomSeverity: String, CaseIterable, Codable {
        case mild = "mild"
        case moderate = "moderate"
        case severe = "severe"
    }
}

struct SkinImage: Identifiable, Codable {
    let id: UUID
    var imageData: Data
    var imageType: ImageType
    var captureDate: Date
    var bodyLocation: BodyLocation
    var magnification: Magnification?
    var lighting: Lighting?
    var notes: String?
    var analysisResults: [AnalysisResult]
    
    init(
        id: UUID = UUID(),
        imageData: Data,
        imageType: ImageType,
        captureDate: Date = Date(),
        bodyLocation: BodyLocation,
        magnification: Magnification? = nil,
        lighting: Lighting? = nil,
        notes: String? = nil,
        analysisResults: [AnalysisResult] = []
    ) {
        self.id = id
        self.imageData = imageData
        self.imageType = imageType
        self.captureDate = captureDate
        self.bodyLocation = bodyLocation
        self.magnification = magnification
        self.lighting = lighting
        self.notes = notes
        self.analysisResults = analysisResults
    }
}

enum ImageType: String, CaseIterable, Codable {
    case clinical = "clinical"
    case dermoscopic = "dermoscopic"
    case pathology = "pathology"
    case totalBodyPhotography = "total_body_photography"
    case macro = "macro"
    case ultraviolet = "ultraviolet"
    case infrared = "infrared"
    
    var displayName: String {
        switch self {
        case .clinical: return "Clinical"
        case .dermoscopic: return "Dermoscopic"
        case .pathology: return "Pathology"
        case .totalBodyPhotography: return "Total Body Photography"
        case .macro: return "Macro"
        case .ultraviolet: return "Ultraviolet"
        case .infrared: return "Infrared"
        }
    }
}

enum Magnification: String, CaseIterable, Codable {
    case x10 = "10x"
    case x20 = "20x"
    case x40 = "40x"
    case x100 = "100x"
    case x200 = "200x"
    case x400 = "400x"
    case other = "other"
}

enum Lighting: String, CaseIterable, Codable {
    case natural = "natural"
    case artificial = "artificial"
    case polarized = "polarized"
    case crossPolarized = "cross_polarized"
    case ultraviolet = "ultraviolet"
    case other = "other"
}

struct AnalysisResult: Identifiable, Codable {
    let id: UUID
    var analysisType: AnalysisType
    var confidence: Double
    var findings: [Finding]
    var recommendations: [Recommendation]
    var modelVersion: String
    var analysisDate: Date
    
    init(
        id: UUID = UUID(),
        analysisType: AnalysisType,
        confidence: Double,
        findings: [Finding] = [],
        recommendations: [Recommendation] = [],
        modelVersion: String = "PanDerm-v1.0",
        analysisDate: Date = Date()
    ) {
        self.id = id
        self.analysisType = analysisType
        self.confidence = confidence
        self.findings = findings
        self.recommendations = recommendations
        self.modelVersion = modelVersion
        self.analysisDate = analysisDate
    }
}

enum AnalysisType: String, CaseIterable, Codable {
    case skinCancerScreening = "skin_cancer_screening"
    case lesionClassification = "lesion_classification"
    case riskAssessment = "risk_assessment"
    case changeDetection = "change_detection"
    case segmentation = "segmentation"
    case phenotypeAnalysis = "phenotype_analysis"
    case metastasisPrediction = "metastasis_prediction"
    
    var displayName: String {
        switch self {
        case .skinCancerScreening: return "Skin Cancer Screening"
        case .lesionClassification: return "Lesion Classification"
        case .riskAssessment: return "Risk Assessment"
        case .changeDetection: return "Change Detection"
        case .segmentation: return "Segmentation"
        case .phenotypeAnalysis: return "Phenotype Analysis"
        case .metastasisPrediction: return "Metastasis Prediction"
        }
    }
}

enum FindingCategory: String, CaseIterable, Codable {
    case suspicious = "suspicious"
    case benign = "benign"
    case malignant = "malignant"
    case inflammatory = "inflammatory"
    case infectious = "infectious"
    case other = "other"
}

struct Finding: Identifiable, Codable {
    var id: UUID
    var description: String
    var confidence: Double
    var category: FindingCategory
    var severity: Severity?
    var location: String?
    var measurements: [SkinMeasurement]?
    
    init(id: UUID = UUID(), description: String, confidence: Double, category: FindingCategory, severity: Severity? = nil, location: String? = nil, measurements: [SkinMeasurement]? = nil) {
        self.id = id
        self.description = description
        self.confidence = confidence
        self.category = category
        self.severity = severity
        self.location = location
        self.measurements = measurements
    }
}

struct SkinMeasurement: Codable {
    var type: MeasurementType
    var value: Double
    var unit: String
    
    enum MeasurementType: String, CaseIterable, Codable {
        case diameter = "diameter"
        case area = "area"
        case depth = "depth"
        case color = "color"
        case texture = "texture"
        case symmetry = "symmetry"
        case border = "border"
    }
}

struct Recommendation: Identifiable, Codable {
    var id: UUID
    var action: String
    var priority: Priority
    var timeframe: String?
    var rationale: String?
    
    init(id: UUID = UUID(), action: String, priority: Priority, timeframe: String? = nil, rationale: String? = nil) {
        self.id = id
        self.action = action
        self.priority = priority
        self.timeframe = timeframe
        self.rationale = rationale
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
    }
}

struct Diagnosis: Codable {
    var primaryDiagnosis: String
    var differentialDiagnoses: [String]
    var confidence: Double
    var diagnosticCriteria: [String]
    var notes: String?
    var date: Date
    var clinician: String?
}

struct TreatmentPlan: Codable {
    var treatments: [Treatment]
    var followUpSchedule: [FollowUp]
    var precautions: [String]
    var expectedOutcome: String?
    var notes: String?
    var createdDate: Date
    var lastModified: Date
    
    struct Treatment: Identifiable, Codable {
        var id: UUID
        var type: TreatmentType
        var name: String
        var dosage: String?
        var frequency: String?
        var duration: String?
        var instructions: String?
        var startDate: Date?
        var endDate: Date?
        var status: TreatmentStatus
        
        init(id: UUID = UUID(), type: TreatmentType, name: String, dosage: String? = nil, frequency: String? = nil, duration: String? = nil, instructions: String? = nil, startDate: Date? = nil, endDate: Date? = nil, status: TreatmentStatus) {
            self.id = id
            self.type = type
            self.name = name
            self.dosage = dosage
            self.frequency = frequency
            self.duration = duration
            self.instructions = instructions
            self.startDate = startDate
            self.endDate = endDate
            self.status = status
        }
        
        enum TreatmentType: String, CaseIterable, Codable {
            case medication = "medication"
            case surgery = "surgery"
            case laser = "laser"
            case cryotherapy = "cryotherapy"
            case phototherapy = "phototherapy"
            case lifestyle = "lifestyle"
            case other = "other"
        }
        
        enum TreatmentStatus: String, CaseIterable, Codable {
            case planned = "planned"
            case active = "active"
            case completed = "completed"
            case discontinued = "discontinued"
        }
    }
    
    struct FollowUp: Identifiable, Codable {
        var id: UUID
        var type: String
        var date: Date
        var purpose: String
        var status: FollowUpStatus
        
        init(id: UUID = UUID(), type: String, date: Date, purpose: String, status: FollowUpStatus) {
            self.id = id
            self.type = type
            self.date = date
            self.purpose = purpose
            self.status = status
        }
        
        enum FollowUpStatus: String, CaseIterable, Codable {
            case scheduled = "scheduled"
            case completed = "completed"
            case cancelled = "cancelled"
            case rescheduled = "rescheduled"
        }
    }
} 
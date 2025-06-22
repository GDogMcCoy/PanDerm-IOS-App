import Foundation

/// Represents a comprehensive medical record in the PanDerm system
/// This model stores all medical information related to a patient
struct MedicalRecord: Identifiable, Codable {
    let id: UUID
    var patientId: UUID
    var recordType: RecordType
    var title: String
    var content: String
    var attachments: [Attachment]
    var tags: [String]
    var priority: Priority
    var status: RecordStatus
    var createdBy: UUID
    var createdAt: Date
    var updatedAt: Date
    var reviewedBy: UUID?
    var reviewedAt: Date?
    
    init(
        id: UUID = UUID(),
        patientId: UUID,
        recordType: RecordType,
        title: String,
        content: String,
        attachments: [Attachment] = [],
        tags: [String] = [],
        priority: Priority = .normal,
        status: RecordStatus = .active,
        createdBy: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        reviewedBy: UUID? = nil,
        reviewedAt: Date? = nil
    ) {
        self.id = id
        self.patientId = patientId
        self.recordType = recordType
        self.title = title
        self.content = content
        self.attachments = attachments
        self.tags = tags
        self.priority = priority
        self.status = status
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reviewedBy = reviewedBy
        self.reviewedAt = reviewedAt
    }
}

// MARK: - Supporting Types

enum RecordType: String, CaseIterable, Codable {
    case clinicalNote = "clinical_note"
    case labResult = "lab_result"
    case pathologyReport = "pathology_report"
    case imagingReport = "imaging_report"
    case treatmentPlan = "treatment_plan"
    case progressNote = "progress_note"
    case consultation = "consultation"
    case referral = "referral"
    case dischargeSummary = "discharge_summary"
    case consent = "consent"
    case allergy = "allergy"
    case medication = "medication"
    case vaccination = "vaccination"
    case familyHistory = "family_history"
    case socialHistory = "social_history"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .clinicalNote: return "Clinical Note"
        case .labResult: return "Lab Result"
        case .pathologyReport: return "Pathology Report"
        case .imagingReport: return "Imaging Report"
        case .treatmentPlan: return "Treatment Plan"
        case .progressNote: return "Progress Note"
        case .consultation: return "Consultation"
        case .referral: return "Referral"
        case .dischargeSummary: return "Discharge Summary"
        case .consent: return "Consent"
        case .allergy: return "Allergy"
        case .medication: return "Medication"
        case .vaccination: return "Vaccination"
        case .familyHistory: return "Family History"
        case .socialHistory: return "Social History"
        case .other: return "Other"
        }
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case urgent = "urgent"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        case .urgent: return "Urgent"
        case .critical: return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .normal: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        case .critical: return "purple"
        }
    }
}

enum RecordStatus: String, CaseIterable, Codable {
    case draft = "draft"
    case active = "active"
    case archived = "archived"
    case deleted = "deleted"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .archived: return "Archived"
        case .deleted: return "Deleted"
        }
    }
}

struct Attachment: Identifiable, Codable {
    let id: UUID
    var fileName: String
    var fileType: FileType
    var fileSize: Int64
    var filePath: String
    var uploadedAt: Date
    var uploadedBy: UUID
    var description: String?
    
    enum FileType: String, CaseIterable, Codable {
        case image = "image"
        case pdf = "pdf"
        case document = "document"
        case video = "video"
        case audio = "audio"
        case other = "other"
    }
}

// MARK: - Lab Results

struct LabResult: Codable {
    var testName: String
    var testCode: String?
    var result: String
    var unit: String?
    var referenceRange: String?
    var isAbnormal: Bool
    var criticalValue: Bool
    var performedAt: Date
    var reportedAt: Date
    var labName: String?
    var orderingProvider: String?
    var notes: String?
    
    var status: LabResultStatus {
        if criticalValue { return .critical }
        if isAbnormal { return .abnormal }
        return .normal
    }
    
    enum LabResultStatus: String, CaseIterable, Codable {
        case normal = "normal"
        case abnormal = "abnormal"
        case critical = "critical"
    }
}

// MARK: - Pathology Reports

struct PathologyReport: Codable {
    var specimenType: String
    var specimenSite: String
    var grossDescription: String?
    var microscopicDescription: String?
    var diagnosis: String
    var diagnosisCode: String?
    var tumorGrade: String?
    var tumorStage: String?
    var margins: String?
    var lymphNodes: String?
    var immunohistochemistry: [String: String]?
    var molecularStudies: [String: String]?
    var pathologist: String?
    var reportDate: Date
    var notes: String?
}

// MARK: - Imaging Reports

struct ImagingReport: Codable {
    var studyType: ImagingStudyType
    var bodyPart: String
    var technique: String?
    var findings: String
    var impression: String
    var radiologist: String?
    var studyDate: Date
    var reportDate: Date
    var images: [String] // File paths or URLs
    var notes: String?
    
    enum ImagingStudyType: String, CaseIterable, Codable {
        case xray = "xray"
        case ct = "ct"
        case mri = "mri"
        case ultrasound = "ultrasound"
        case mammography = "mammography"
        case pet = "pet"
        case other = "other"
    }
}

// MARK: - Clinical Notes

struct ClinicalNote: Codable {
    var noteType: ClinicalNoteType
    var subjective: String
    var objective: String
    var assessment: String
    var plan: String
    var vitalSigns: VitalSigns?
    var physicalExam: PhysicalExam?
    var medications: [String]
    var allergies: [String]
    var followUpPlan: String?
    
    enum ClinicalNoteType: String, CaseIterable, Codable {
        case initial = "initial"
        case followUp = "follow_up"
        case progress = "progress"
        case discharge = "discharge"
        case consultation = "consultation"
        case procedure = "procedure"
    }
}

struct VitalSigns: Codable {
    var temperature: Double?
    var heartRate: Int?
    var bloodPressure: String?
    var respiratoryRate: Int?
    var oxygenSaturation: Int?
    var weight: Double?
    var height: Double?
    var bmi: Double?
    var recordedAt: Date
}

struct PhysicalExam: Codable {
    var general: String?
    var skin: String?
    var head: String?
    var eyes: String?
    var ears: String?
    var nose: String?
    var throat: String?
    var neck: String?
    var chest: String?
    var cardiovascular: String?
    var abdomen: String?
    var extremities: String?
    var neurological: String?
    var other: String?
}

// MARK: - Medication Records

struct MedicationRecord: Codable {
    var medicationName: String
    var genericName: String?
    var dosage: String
    var frequency: String
    var route: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var prescribedBy: String?
    var pharmacy: String?
    var refills: Int?
    var instructions: String?
    var sideEffects: [String]?
    var effectiveness: MedicationEffectiveness?
    var notes: String?
    
    enum MedicationEffectiveness: String, CaseIterable, Codable {
        case excellent = "excellent"
        case good = "good"
        case fair = "fair"
        case poor = "poor"
        case unknown = "unknown"
    }
}

// MARK: - Allergy Records

struct AllergyRecord: Codable {
    var allergen: String
    var allergyType: AllergyType
    var severity: AllergySeverity
    var reaction: String
    var onsetDate: Date?
    var isActive: Bool
    var notes: String?
    
    enum AllergyType: String, CaseIterable, Codable {
        case drug = "drug"
        case food = "food"
        case environmental = "environmental"
        case latex = "latex"
        case other = "other"
    }
    
    enum AllergySeverity: String, CaseIterable, Codable {
        case mild = "mild"
        case moderate = "moderate"
        case severe = "severe"
        case lifeThreatening = "life_threatening"
    }
}

// MARK: - Medical Record Timeline

struct MedicalRecordTimeline: Codable {
    var patientId: UUID
    var records: [MedicalRecord]
    var timelineEvents: [TimelineEvent]
    
    struct TimelineEvent: Identifiable, Codable {
        var id: UUID
        var date: Date
        var eventType: EventType
        var title: String
        var description: String
        var recordId: UUID?
        var tags: [String]
        
        init(id: UUID = UUID(), date: Date, eventType: EventType, title: String, description: String, recordId: UUID? = nil, tags: [String]) {
            self.id = id
            self.date = date
            self.eventType = eventType
            self.title = title
            self.description = description
            self.recordId = recordId
            self.tags = tags
        }
        
        enum EventType: String, CaseIterable, Codable {
            case appointment = "appointment"
            case diagnosis = "diagnosis"
            case treatment = "treatment"
            case labResult = "lab_result"
            case medication = "medication"
            case surgery = "surgery"
            case allergy = "allergy"
            case other = "other"
        }
    }
} 
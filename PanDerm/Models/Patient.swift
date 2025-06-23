import Foundation

/// Represents a patient in the PanDerm system
/// This model stores comprehensive patient information for dermatological analysis
struct Patient: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var medicalRecordNumber: String
    var emergencyContact: String?
    var allergies: String?
    var currentMedications: String?
    var notes: String?
    var medicalRecords: [MedicalRecord]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        medicalRecordNumber: String,
        emergencyContact: String? = nil,
        allergies: String? = nil,
        currentMedications: String? = nil,
        notes: String? = nil,
        medicalRecords: [MedicalRecord] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.medicalRecordNumber = medicalRecordNumber
        self.emergencyContact = emergencyContact
        self.allergies = allergies
        self.currentMedications = currentMedications
        self.notes = notes
        self.medicalRecords = medicalRecords
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var analysisCount: Int {
        medicalRecords.flatMap { $0.analysisResults }.count
    }
    
    #if DEBUG
    static let sampleData: [Patient] = [
        Patient(
            firstName: "John",
            lastName: "Appleseed",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date())!,
            medicalRecordNumber: "MRN001",
            emergencyContact: "Jane Appleseed (Wife) - 555-123-4567",
            allergies: "Penicillin",
            currentMedications: "Lisinopril 10mg daily",
            notes: "History of atypical moles",
            medicalRecords: [
                MedicalRecord(
                    date: Date(),
                    chiefComplaint: "Routine skin check",
                    notes: "Annual dermatology examination",
                    analysisResults: []
                )
            ]
        ),
        Patient(
            firstName: "Jane",
            lastName: "Doe",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -32, to: Date())!,
            medicalRecordNumber: "MRN002",
            emergencyContact: "John Doe (Husband) - 555-987-6543",
            allergies: "None known",
            currentMedications: "Birth control",
            notes: "Fair skin, family history of melanoma",
            medicalRecords: []
        )
    ]
    #endif
}

// MARK: - Supporting Types

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

enum Ethnicity: String, CaseIterable, Codable {
    case white = "white"
    case black = "black"
    case hispanic = "hispanic"
    case asian = "asian"
    case pacificIslander = "pacific_islander"
    case nativeAmerican = "native_american"
    case mixed = "mixed"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .white: return "White"
        case .black: return "Black"
        case .hispanic: return "Hispanic"
        case .asian: return "Asian"
        case .pacificIslander: return "Pacific Islander"
        case .nativeAmerican: return "Native American"
        case .mixed: return "Mixed"
        case .other: return "Other"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

enum FitzpatrickSkinType: Int, CaseIterable, Codable {
    case type1 = 1
    case type2 = 2
    case type3 = 3
    case type4 = 4
    case type5 = 5
    case type6 = 6
    
    var displayName: String {
        switch self {
        case .type1: return "Type I - Always burns, never tans"
        case .type2: return "Type II - Usually burns, tans minimally"
        case .type3: return "Type III - Sometimes burns, tans uniformly"
        case .type4: return "Type IV - Rarely burns, tans easily"
        case .type5: return "Type V - Very rarely burns, tans very easily"
        case .type6: return "Type VI - Never burns, deeply pigmented"
        }
    }
    
    var riskLevel: String {
        switch self {
        case .type1, .type2: return "High"
        case .type3, .type4: return "Medium"
        case .type5, .type6: return "Low"
        }
    }
}

// MARK: - Medical Records

struct MedicalRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var chiefComplaint: String
    var presentIllness: String?
    var physicalExam: String?
    var assessment: String?
    var plan: String?
    var notes: String?
    var analysisResults: [AnalysisSession]
    var attachments: [MedicalAttachment]
    
    init(
        id: UUID = UUID(),
        date: Date,
        chiefComplaint: String,
        presentIllness: String? = nil,
        physicalExam: String? = nil,
        assessment: String? = nil,
        plan: String? = nil,
        notes: String? = nil,
        analysisResults: [AnalysisSession] = [],
        attachments: [MedicalAttachment] = []
    ) {
        self.id = id
        self.date = date
        self.chiefComplaint = chiefComplaint
        self.presentIllness = presentIllness
        self.physicalExam = physicalExam
        self.assessment = assessment
        self.plan = plan
        self.notes = notes
        self.analysisResults = analysisResults
        self.attachments = attachments
    }
}

struct MedicalAttachment: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: AttachmentType
    var fileData: Data
    var uploadDate: Date
    var notes: String?
    
    enum AttachmentType: String, CaseIterable, Codable {
        case image = "image"
        case document = "document"
        case report = "report"
        case labResult = "lab_result"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .image: return "Image"
            case .document: return "Document"
            case .report: return "Report"
            case .labResult: return "Lab Result"
            case .other: return "Other"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        type: AttachmentType,
        fileData: Data,
        uploadDate: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.fileData = fileData
        self.uploadDate = uploadDate
        self.notes = notes
    }
}

// MARK: - Treatment Plans

struct TreatmentPlan: Identifiable, Codable {
    let id: UUID
    var diagnosis: String
    var recommendations: [TreatmentRecommendation]
    var followUpDate: Date?
    var urgency: TreatmentUrgency
    var notes: String?
    var createdDate: Date
    
    enum TreatmentUrgency: String, CaseIterable, Codable {
        case routine = "routine"
        case urgent = "urgent"
        case emergency = "emergency"
        
        var displayName: String {
            switch self {
            case .routine: return "Routine"
            case .urgent: return "Urgent"
            case .emergency: return "Emergency"
            }
        }
        
        var color: String {
            switch self {
            case .routine: return "green"
            case .urgent: return "orange"
            case .emergency: return "red"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        diagnosis: String,
        recommendations: [TreatmentRecommendation] = [],
        followUpDate: Date? = nil,
        urgency: TreatmentUrgency = .routine,
        notes: String? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.diagnosis = diagnosis
        self.recommendations = recommendations
        self.followUpDate = followUpDate
        self.urgency = urgency
        self.notes = notes
        self.createdDate = createdDate
    }
}

struct TreatmentRecommendation: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var priority: RecommendationPriority
    var completed: Bool
    var completedDate: Date?
    var notes: String?
    
    enum RecommendationPriority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        var displayName: String {
            switch self {
            case .low: return "Low Priority"
            case .medium: return "Medium Priority"
            case .high: return "High Priority"
            case .critical: return "Critical"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        priority: RecommendationPriority = .medium,
        completed: Bool = false,
        completedDate: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.completed = completed
        self.completedDate = completedDate
        self.notes = notes
    }
} 
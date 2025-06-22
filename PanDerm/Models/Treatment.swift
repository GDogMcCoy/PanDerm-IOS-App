import Foundation

/// Represents a treatment plan in the PanDerm system
/// This model manages comprehensive treatment protocols for skin conditions
struct Treatment: Identifiable, Codable {
    let id: UUID
    var patientId: UUID
    var conditionId: UUID
    var treatmentType: TreatmentType
    var status: TreatmentStatus
    var startDate: Date
    var endDate: Date?
    var duration: String?
    var dosage: String?
    var frequency: String?
    var instructions: String?
    var sideEffects: [String]
    var contraindications: [String]
    var followUpSchedule: [FollowUp]
    var progressNotes: [ProgressNote]
    var outcomes: [Outcome]
    var prescribedBy: UUID
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        patientId: UUID,
        conditionId: UUID,
        treatmentType: TreatmentType,
        status: TreatmentStatus = .planned,
        startDate: Date,
        endDate: Date? = nil,
        duration: String? = nil,
        dosage: String? = nil,
        frequency: String? = nil,
        instructions: String? = nil,
        sideEffects: [String] = [],
        contraindications: [String] = [],
        followUpSchedule: [FollowUp] = [],
        progressNotes: [ProgressNote] = [],
        outcomes: [Outcome] = [],
        prescribedBy: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.patientId = patientId
        self.conditionId = conditionId
        self.treatmentType = treatmentType
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.dosage = dosage
        self.frequency = frequency
        self.instructions = instructions
        self.sideEffects = sideEffects
        self.contraindications = contraindications
        self.followUpSchedule = followUpSchedule
        self.progressNotes = progressNotes
        self.outcomes = outcomes
        self.prescribedBy = prescribedBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var isActive: Bool {
        status == .active
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var durationInDays: Int? {
        guard let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
    }
}

// MARK: - Supporting Types

enum TreatmentType: String, CaseIterable, Codable {
    case medication = "medication"
    case surgery = "surgery"
    case laser = "laser"
    case cryotherapy = "cryotherapy"
    case phototherapy = "phototherapy"
    case radiation = "radiation"
    case immunotherapy = "immunotherapy"
    case targetedTherapy = "targeted_therapy"
    case chemotherapy = "chemotherapy"
    case lifestyle = "lifestyle"
    case watchfulWaiting = "watchful_waiting"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .medication: return "Medication"
        case .surgery: return "Surgery"
        case .laser: return "Laser Therapy"
        case .cryotherapy: return "Cryotherapy"
        case .phototherapy: return "Phototherapy"
        case .radiation: return "Radiation Therapy"
        case .immunotherapy: return "Immunotherapy"
        case .targetedTherapy: return "Targeted Therapy"
        case .chemotherapy: return "Chemotherapy"
        case .lifestyle: return "Lifestyle Modification"
        case .watchfulWaiting: return "Watchful Waiting"
        case .other: return "Other"
        }
    }
}

enum TreatmentStatus: String, CaseIterable, Codable {
    case planned = "planned"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case discontinued = "discontinued"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .planned: return "Planned"
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .discontinued: return "Discontinued"
        case .failed: return "Failed"
        }
    }
    
    var color: String {
        switch self {
        case .planned: return "blue"
        case .active: return "green"
        case .paused: return "yellow"
        case .completed: return "green"
        case .discontinued: return "red"
        case .failed: return "red"
        }
    }
}

struct FollowUp: Identifiable, Codable {
    let id: UUID
    var type: FollowUpType
    var scheduledDate: Date
    var status: FollowUpStatus
    var purpose: String
    var notes: String?
    var completedDate: Date?
    var findings: String?
    
    init(
        id: UUID = UUID(),
        type: FollowUpType,
        scheduledDate: Date,
        status: FollowUpStatus = .scheduled,
        purpose: String,
        notes: String? = nil,
        completedDate: Date? = nil,
        findings: String? = nil
    ) {
        self.id = id
        self.type = type
        self.scheduledDate = scheduledDate
        self.status = status
        self.purpose = purpose
        self.notes = notes
        self.completedDate = completedDate
        self.findings = findings
    }
}

enum FollowUpType: String, CaseIterable, Codable {
    case clinical = "clinical"
    case imaging = "imaging"
    case lab = "lab"
    case pathology = "pathology"
    case consultation = "consultation"
    case surgery = "surgery"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .clinical: return "Clinical"
        case .imaging: return "Imaging"
        case .lab: return "Lab"
        case .pathology: return "Pathology"
        case .consultation: return "Consultation"
        case .surgery: return "Surgery"
        case .other: return "Other"
        }
    }
}

enum FollowUpStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case completed = "completed"
    case cancelled = "cancelled"
    case rescheduled = "rescheduled"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .rescheduled: return "Rescheduled"
        case .noShow: return "No Show"
        }
    }
}

struct ProgressNote: Identifiable, Codable {
    let id: UUID
    var date: Date
    var subjective: String
    var objective: String
    var assessment: String
    var plan: String
    var sideEffects: [String]
    var adherence: Adherence
    var effectiveness: Effectiveness
    var notes: String?
    var createdBy: UUID
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        subjective: String,
        objective: String,
        assessment: String,
        plan: String,
        sideEffects: [String] = [],
        adherence: Adherence = .good,
        effectiveness: Effectiveness = .unknown,
        notes: String? = nil,
        createdBy: UUID
    ) {
        self.id = id
        self.date = date
        self.subjective = subjective
        self.objective = objective
        self.assessment = assessment
        self.plan = plan
        self.sideEffects = sideEffects
        self.adherence = adherence
        self.effectiveness = effectiveness
        self.notes = notes
        self.createdBy = createdBy
    }
}

enum Adherence: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .unknown: return "Unknown"
        }
    }
}

enum Effectiveness: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .unknown: return "Unknown"
        }
    }
}

struct Outcome: Identifiable, Codable {
    let id: UUID
    var type: OutcomeType
    var date: Date
    var description: String
    var measurements: [TreatmentMeasurement]
    var success: Bool
    var notes: String?
    
    init(
        id: UUID = UUID(),
        type: OutcomeType,
        date: Date = Date(),
        description: String,
        measurements: [TreatmentMeasurement] = [],
        success: Bool,
        notes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.description = description
        self.measurements = measurements
        self.success = success
        self.notes = notes
    }
}

enum OutcomeType: String, CaseIterable, Codable {
    case clinical = "clinical"
    case imaging = "imaging"
    case lab = "lab"
    case pathology = "pathology"
    case qualityOfLife = "quality_of_life"
    case survival = "survival"
    case recurrence = "recurrence"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .clinical: return "Clinical"
        case .imaging: return "Imaging"
        case .lab: return "Lab"
        case .pathology: return "Pathology"
        case .qualityOfLife: return "Quality of Life"
        case .survival: return "Survival"
        case .recurrence: return "Recurrence"
        case .other: return "Other"
        }
    }
}

struct TreatmentMeasurement: Codable {
    var name: String
    var value: String
    var unit: String?
    var baseline: String?
    var change: String?
    var normalRange: String?
}

// MARK: - Treatment Protocols

struct TreatmentProtocol: Codable {
    var name: String
    var description: String
    var conditionType: [String]
    var stages: [ProtocolStage]
    var medications: [ProtocolMedication]
    var monitoring: [MonitoringRequirement]
    var contraindications: [String]
    var references: [String]
    var version: String
    var lastUpdated: Date
    
    struct ProtocolStage: Identifiable, Codable {
        var id: UUID
        var name: String
        var duration: String
        var treatments: [String]
        var criteria: [String]
        var outcomes: [String]
        
        init(id: UUID = UUID(), name: String, duration: String, treatments: [String], criteria: [String], outcomes: [String]) {
            self.id = id
            self.name = name
            self.duration = duration
            self.treatments = treatments
            self.criteria = criteria
            self.outcomes = outcomes
        }
    }
    
    struct ProtocolMedication: Identifiable, Codable {
        var id: UUID
        var name: String
        var dosage: String
        var frequency: String
        var duration: String
        var route: String
        var monitoring: [String]
        
        init(id: UUID = UUID(), name: String, dosage: String, frequency: String, duration: String, route: String, monitoring: [String]) {
            self.id = id
            self.name = name
            self.dosage = dosage
            self.frequency = frequency
            self.duration = duration
            self.route = route
            self.monitoring = monitoring
        }
    }
    
    struct MonitoringRequirement: Identifiable, Codable {
        var id: UUID
        var type: String
        var frequency: String
        var parameters: [String]
        var thresholds: [String]
        
        init(id: UUID = UUID(), type: String, frequency: String, parameters: [String], thresholds: [String]) {
            self.id = id
            self.type = type
            self.frequency = frequency
            self.parameters = parameters
            self.thresholds = thresholds
        }
    }
}

// MARK: - Treatment Statistics

struct TreatmentStatistics: Codable {
    var totalTreatments: Int
    var activeTreatments: Int
    var completedTreatments: Int
    var discontinuedTreatments: Int
    var averageDuration: TimeInterval
    var successRate: Double
    var commonSideEffects: [String: Int]
    var treatmentTypeDistribution: [TreatmentType: Int]
    
    var completionRate: Double {
        guard totalTreatments > 0 else { return 0 }
        return Double(completedTreatments) / Double(totalTreatments) * 100
    }
    
    var discontinuationRate: Double {
        guard totalTreatments > 0 else { return 0 }
        return Double(discontinuedTreatments) / Double(totalTreatments) * 100
    }
} 
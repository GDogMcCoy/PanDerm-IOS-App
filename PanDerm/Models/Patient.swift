import Foundation

/// Represents a patient in the PanDerm system
/// This model stores comprehensive patient information for dermatological analysis
struct Patient: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var gender: Gender
    var ethnicity: Ethnicity?
    var skinType: FitzpatrickSkinType?
    var contactInfo: ContactInfo
    var medicalHistory: MedicalHistory
    var riskFactors: RiskFactors
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        gender: Gender,
        ethnicity: Ethnicity? = nil,
        skinType: FitzpatrickSkinType? = nil,
        contactInfo: ContactInfo,
        medicalHistory: MedicalHistory = MedicalHistory(),
        riskFactors: RiskFactors = RiskFactors(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.ethnicity = ethnicity
        self.skinType = skinType
        self.contactInfo = contactInfo
        self.medicalHistory = medicalHistory
        self.riskFactors = riskFactors
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
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

struct ContactInfo: Codable {
    var email: String?
    var phone: String?
    var address: Address?
    var emergencyContact: EmergencyContact?
    
    struct Address: Codable {
        var street: String
        var city: String
        var state: String
        var zipCode: String
        var country: String
    }
    
    struct EmergencyContact: Codable {
        var name: String
        var relationship: String
        var phone: String
        var email: String?
    }
}

struct MedicalHistory: Codable {
    var previousSkinConditions: [SkinCondition] = []
    var previousSurgeries: [Surgery] = []
    var medications: [Medication] = []
    var allergies: [Allergy] = []
    var familyHistory: FamilyHistory = FamilyHistory()
    var lifestyleFactors: LifestyleFactors = LifestyleFactors()
    
    struct Surgery: Codable, Identifiable {
        var id: UUID
        var procedure: String
        var date: Date
        var surgeon: String?
        var notes: String?
        
        init(id: UUID = UUID(), procedure: String, date: Date, surgeon: String? = nil, notes: String? = nil) {
            self.id = id
            self.procedure = procedure
            self.date = date
            self.surgeon = surgeon
            self.notes = notes
        }
    }
    
    struct Medication: Codable, Identifiable {
        var id: UUID
        var name: String
        var dosage: String
        var frequency: String
        var startDate: Date
        var endDate: Date?
        var isActive: Bool
        var notes: String?
        
        init(id: UUID = UUID(), name: String, dosage: String, frequency: String, startDate: Date, endDate: Date? = nil, isActive: Bool, notes: String? = nil) {
            self.id = id
            self.name = name
            self.dosage = dosage
            self.frequency = frequency
            self.startDate = startDate
            self.endDate = endDate
            self.isActive = isActive
            self.notes = notes
        }
    }
    
    struct Allergy: Codable, Identifiable {
        var id: UUID
        var allergen: String
        var severity: AllergySeverity
        var reaction: String
        var notes: String?
        
        init(id: UUID = UUID(), allergen: String, severity: AllergySeverity, reaction: String, notes: String? = nil) {
            self.id = id
            self.allergen = allergen
            self.severity = severity
            self.reaction = reaction
            self.notes = notes
        }
    }
    
    enum AllergySeverity: String, CaseIterable, Codable {
        case mild = "mild"
        case moderate = "moderate"
        case severe = "severe"
        case lifeThreatening = "life_threatening"
    }
}

struct FamilyHistory: Codable {
    var melanoma: Bool = false
    var otherSkinCancers: Bool = false
    var autoimmuneConditions: Bool = false
    var details: String = ""
}

struct LifestyleFactors: Codable {
    var sunExposure: SunExposure = .moderate
    var tanningBedUse: Bool = false
    var smoking: Bool = false
    var alcoholConsumption: AlcoholConsumption = .none
    var occupation: String = ""
    var outdoorActivities: [String] = []
    
    enum SunExposure: String, CaseIterable, Codable {
        case minimal = "minimal"
        case moderate = "moderate"
        case high = "high"
        case veryHigh = "very_high"
    }
    
    enum AlcoholConsumption: String, CaseIterable, Codable {
        case none = "none"
        case occasional = "occasional"
        case moderate = "moderate"
        case heavy = "heavy"
    }
}

struct RiskFactors: Codable {
    var fairSkin: Bool = false
    var lightHair: Bool = false
    var lightEyes: Bool = false
    var freckles: Bool = false
    var manyMoles: Bool = false
    var atypicalMoles: Bool = false
    var severeSunburns: Bool = false
    var familyHistory: Bool = false
    var personalHistory: Bool = false
    var immunosuppression: Bool = false
    var xerodermaPigmentosum: Bool = false
    
    var riskScore: Int {
        var score = 0
        if fairSkin { score += 1 }
        if lightHair { score += 1 }
        if lightEyes { score += 1 }
        if freckles { score += 1 }
        if manyMoles { score += 2 }
        if atypicalMoles { score += 2 }
        if severeSunburns { score += 1 }
        if familyHistory { score += 2 }
        if personalHistory { score += 3 }
        if immunosuppression { score += 2 }
        if xerodermaPigmentosum { score += 5 }
        return score
    }
    
    var riskLevel: String {
        switch riskScore {
        case 0...2: return "Low"
        case 3...5: return "Medium"
        case 6...8: return "High"
        default: return "Very High"
        }
    }
} 
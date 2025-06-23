import Foundation

/// Represents a skin condition or lesion in the PanDerm system
struct SkinCondition: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: SkinConditionCategory
    var severity: Severity
    var bodyLocation: BodyLocation
    var symptoms: [Symptom]
    var images: [SkinImage] // This now refers to the Codable SkinImage from AnalysisModels.swift
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    // The `analysisResults` property which was causing Codable issues has been removed.
    // Analysis results are now transient and held in the ViewModel.
    
    init(
        id: UUID = UUID(),
        name: String,
        category: SkinConditionCategory,
        severity: Severity = .mild,
        bodyLocation: BodyLocation,
        symptoms: [Symptom] = [],
        images: [SkinImage] = [],
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
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Supporting Enums

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

// NOTE: The old definitions for SkinImage, AnalysisResult, and other related structs
// have been REMOVED from this file to resolve compilation errors.
// The new canonical definitions are in AnalysisModels.swift.

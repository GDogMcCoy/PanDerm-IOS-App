import Foundation

/// Represents an appointment in the PanDerm system
/// This model manages patient appointments and scheduling
struct Appointment: Identifiable, Codable {
    let id: UUID
    var patientId: UUID
    var clinicianId: UUID?
    var appointmentType: AppointmentType
    var status: AppointmentStatus
    var scheduledDate: Date
    var duration: TimeInterval
    var location: String?
    var notes: String?
    var reason: String?
    var followUpFrom: UUID? // Reference to previous appointment
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        patientId: UUID,
        clinicianId: UUID? = nil,
        appointmentType: AppointmentType,
        status: AppointmentStatus = .scheduled,
        scheduledDate: Date,
        duration: TimeInterval = 1800, // 30 minutes default
        location: String? = nil,
        notes: String? = nil,
        reason: String? = nil,
        followUpFrom: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.patientId = patientId
        self.clinicianId = clinicianId
        self.appointmentType = appointmentType
        self.status = status
        self.scheduledDate = scheduledDate
        self.duration = duration
        self.location = location
        self.notes = notes
        self.reason = reason
        self.followUpFrom = followUpFrom
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var endTime: Date {
        scheduledDate.addingTimeInterval(duration)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }
    
    var isUpcoming: Bool {
        scheduledDate > Date()
    }
    
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        return "\(minutes) minutes"
    }
}

// MARK: - Supporting Types

enum AppointmentType: String, CaseIterable, Codable {
    case initialConsultation = "initial_consultation"
    case followUp = "follow_up"
    case skinCancerScreening = "skin_cancer_screening"
    case lesionExcision = "lesion_excision"
    case biopsy = "biopsy"
    case treatment = "treatment"
    case emergency = "emergency"
    case telemedicine = "telemedicine"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .initialConsultation: return "Initial Consultation"
        case .followUp: return "Follow-up"
        case .skinCancerScreening: return "Skin Cancer Screening"
        case .lesionExcision: return "Lesion Excision"
        case .biopsy: return "Biopsy"
        case .treatment: return "Treatment"
        case .emergency: return "Emergency"
        case .telemedicine: return "Telemedicine"
        case .other: return "Other"
        }
    }
    
    var defaultDuration: TimeInterval {
        switch self {
        case .initialConsultation: return 3600 // 1 hour
        case .followUp: return 1800 // 30 minutes
        case .skinCancerScreening: return 2700 // 45 minutes
        case .lesionExcision: return 3600 // 1 hour
        case .biopsy: return 1800 // 30 minutes
        case .treatment: return 2700 // 45 minutes
        case .emergency: return 1800 // 30 minutes
        case .telemedicine: return 1800 // 30 minutes
        case .other: return 1800 // 30 minutes
        }
    }
}

enum AppointmentStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    case rescheduled = "rescheduled"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .confirmed: return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "No Show"
        case .rescheduled: return "Rescheduled"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .confirmed: return "green"
        case .inProgress: return "orange"
        case .completed: return "green"
        case .cancelled: return "red"
        case .noShow: return "red"
        case .rescheduled: return "yellow"
        }
    }
}

// MARK: - Appointment Schedule

struct AppointmentSchedule: Codable {
    var clinicianId: UUID
    var workingHours: WorkingHours
    var availability: [TimeSlot]
    var blockedDates: [Date]
    var notes: String?
    
    struct WorkingHours: Codable {
        var monday: DaySchedule?
        var tuesday: DaySchedule?
        var wednesday: DaySchedule?
        var thursday: DaySchedule?
        var friday: DaySchedule?
        var saturday: DaySchedule?
        var sunday: DaySchedule?
        
        struct DaySchedule: Codable {
            var startTime: Date
            var endTime: Date
            var isAvailable: Bool = true
        }
    }
    
    struct TimeSlot: Codable, Identifiable {
        var id: UUID
        var date: Date
        var startTime: Date
        var endTime: Date
        var isAvailable: Bool
        var appointmentId: UUID?
        
        init(id: UUID = UUID(), date: Date, startTime: Date, endTime: Date, isAvailable: Bool, appointmentId: UUID? = nil) {
            self.id = id
            self.date = date
            self.startTime = startTime
            self.endTime = endTime
            self.isAvailable = isAvailable
            self.appointmentId = appointmentId
        }
        
        var duration: TimeInterval {
            endTime.timeIntervalSince(startTime)
        }
    }
}

// MARK: - Appointment Reminders

struct AppointmentReminder: Identifiable, Codable {
    let id: UUID
    var appointmentId: UUID
    var reminderType: ReminderType
    var scheduledTime: Date
    var sentTime: Date?
    var status: ReminderStatus
    var message: String?
    
    enum ReminderType: String, CaseIterable, Codable {
        case sms = "sms"
        case email = "email"
        case push = "push"
        case phone = "phone"
    }
    
    enum ReminderStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case sent = "sent"
        case failed = "failed"
        case cancelled = "cancelled"
    }
}

// MARK: - Appointment Notes

struct AppointmentNote: Identifiable, Codable {
    let id: UUID
    var appointmentId: UUID
    var clinicianId: UUID
    var noteType: NoteType
    var content: String
    var attachments: [String] // File paths or URLs
    var createdAt: Date
    var updatedAt: Date
    
    enum NoteType: String, CaseIterable, Codable {
        case clinical = "clinical"
        case administrative = "administrative"
        case patient = "patient"
        case followUp = "follow_up"
    }
}

// MARK: - Appointment Statistics

struct AppointmentStatistics: Codable {
    var totalAppointments: Int
    var completedAppointments: Int
    var cancelledAppointments: Int
    var noShows: Int
    var averageDuration: TimeInterval
    var mostCommonType: AppointmentType?
    var busiestDay: String?
    var busiestHour: Int?
    
    var completionRate: Double {
        guard totalAppointments > 0 else { return 0 }
        return Double(completedAppointments) / Double(totalAppointments) * 100
    }
    
    var cancellationRate: Double {
        guard totalAppointments > 0 else { return 0 }
        return Double(cancelledAppointments) / Double(totalAppointments) * 100
    }
    
    var noShowRate: Double {
        guard totalAppointments > 0 else { return 0 }
        return Double(noShows) / Double(totalAppointments) * 100
    }
} 
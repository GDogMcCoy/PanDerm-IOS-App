import Foundation
import Combine

@MainActor
class AnalysisHistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var analyses: [AnalysisRecord] = []
    @Published var filteredAnalyses: [AnalysisRecord] = []
    @Published var selectedFilter: AnalysisFilter = .all {
        didSet {
            applyFilters()
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let historyService = AnalysisHistoryService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        applyFilters()
    }
    
    // MARK: - Data Loading
    
    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Convert AnalysisResult to AnalysisRecord for history display
            let analysisResults = try await historyService.loadAnalysisHistory()
            analyses = analysisResults.map { convertToAnalysisRecord($0) }
            applyFilters()
            isLoading = false
        } catch {
            errorMessage = "Failed to load analysis history: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func refreshHistory() async {
        await loadHistory()
    }
    
    // MARK: - Filtering
    
    private func applyFilters() {
        switch selectedFilter {
        case .all:
            filteredAnalyses = analyses
        case .highRisk:
            filteredAnalyses = analyses.filter { $0.riskLevel == .high || $0.riskLevel == .critical }
        case .recent:
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            filteredAnalyses = analyses.filter { $0.createdAt >= thirtyDaysAgo }
        case .flagged:
            filteredAnalyses = analyses.filter { $0.isFlagged }
        }
    }
    
    // MARK: - Analysis Management
    
    func deleteAnalysis(_ analysis: AnalysisRecord) {
        analyses.removeAll { $0.id == analysis.id }
        applyFilters()
        
        Task {
            do {
                try await historyService.deleteAnalysis(analysis.id)
            } catch {
                errorMessage = "Failed to delete analysis: \(error.localizedDescription)"
                // Re-add if deletion fails
                analyses.append(analysis)
                applyFilters()
            }
        }
    }
    
    func flagAnalysis(_ analysis: AnalysisRecord) {
        if let index = analyses.firstIndex(where: { $0.id == analysis.id }) {
            let updatedAnalysis = AnalysisRecord(
                id: analysis.id,
                patientId: analysis.patientId,
                patientName: analysis.patientName,
                imageURL: analysis.imageURL,
                thumbnailURL: analysis.thumbnailURL,
                primaryDiagnosis: analysis.primaryDiagnosis,
                confidence: analysis.confidence,
                riskLevel: analysis.riskLevel,
                createdAt: analysis.createdAt,
                isFlagged: !analysis.isFlagged,
                hasFollowUp: analysis.hasFollowUp,
                recommendations: analysis.recommendations,
                notes: analysis.notes
            )
            
            analyses[index] = updatedAnalysis
            applyFilters()
            
            Task {
                do {
                    try await historyService.updateAnalysis(updatedAnalysis)
                } catch {
                    errorMessage = "Failed to update analysis: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func clearAllHistory() {
        analyses.removeAll()
        applyFilters()
        
        Task {
            do {
                try await historyService.clearAllHistory()
            } catch {
                errorMessage = "Failed to clear history: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Search
    
    func searchAnalyses(query: String) {
        if query.isEmpty {
            applyFilters()
        } else {
            let searchResults = analyses.filter { analysis in
                analysis.primaryDiagnosis.localizedCaseInsensitiveContains(query) ||
                analysis.patientName?.localizedCaseInsensitiveContains(query) == true ||
                analysis.recommendations.contains { $0.localizedCaseInsensitiveContains(query) }
            }
            filteredAnalyses = searchResults
        }
    }
    
    // MARK: - Export
    
    func exportData(format: ExportFormat, dateRange: DateRange) async throws -> URL {
        let analysesToExport = getAnalysesForDateRange(dateRange)
        
        switch format {
        case .pdf:
            return try await exportToPDF(analyses: analysesToExport)
        case .csv:
            return try await exportToCSV(analyses: analysesToExport)
        case .json:
            return try await exportToJSON(analyses: analysesToExport)
        }
    }
    
    private func getAnalysesForDateRange(_ dateRange: DateRange) -> [AnalysisRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch dateRange {
        case .last30Days:
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .last3Months:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .allTime:
            return analyses
        }
        
        return analyses.filter { $0.createdAt >= startDate }
    }
    
    private func exportToPDF(analyses: [AnalysisRecord]) async throws -> URL {
        // Implement PDF export
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("panderm_export.pdf")
        // TODO: Implement actual PDF generation
        return tempURL
    }
    
    private func exportToCSV(analyses: [AnalysisRecord]) async throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("panderm_export.csv")
        
        var csvContent = "Date,Patient,Diagnosis,Confidence,Risk Level,Flagged,Recommendations\n"
        
        for analysis in analyses {
            let row = [
                analysis.createdAt.formatted(.iso8601),
                analysis.patientName ?? "Unknown",
                analysis.primaryDiagnosis,
                String(format: "%.2f", analysis.confidence),
                analysis.riskLevel.rawValue,
                String(analysis.isFlagged),
                analysis.recommendations.joined(separator: "; ")
            ].joined(separator: ",")
            
            csvContent += row + "\n"
        }
        
        try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }
    
    private func exportToJSON(analyses: [AnalysisRecord]) async throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("panderm_export.json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(analyses)
        try data.write(to: tempURL)
        
        return tempURL
    }
    
    // MARK: - Statistics
    
    var totalAnalyses: Int {
        analyses.count
    }
    
    var flaggedAnalyses: Int {
        analyses.filter { $0.isFlagged }.count
    }
    
    var highRiskAnalyses: Int {
        analyses.filter { $0.riskLevel == .high || $0.riskLevel == .critical }.count
    }
    
    var averageConfidence: Double {
        guard !analyses.isEmpty else { return 0 }
        let totalConfidence = analyses.reduce(0) { $0 + $1.confidence }
        return totalConfidence / Double(analyses.count)
    }
    
    var analysesThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return analyses.filter { $0.createdAt >= weekAgo }.count
    }
    
    // MARK: - Helper Methods
    
    private func convertToAnalysisRecord(_ result: AnalysisResult) -> AnalysisRecord {
        let primaryDiagnosis = result.classifications.first?.label ?? "Unknown"
        let confidence = result.classifications.first?.confidence ?? 0.0
        let riskLevel = determineRiskLevel(from: result)
        let recommendations = result.recommendations.map { $0.description }
        
        return AnalysisRecord(
            primaryDiagnosis: primaryDiagnosis,
            confidence: confidence,
            riskLevel: riskLevel,
            createdAt: result.createdAt,
            recommendations: recommendations
        )
    }
    
    private func determineRiskLevel(from result: AnalysisResult) -> RiskLevel {
        let malignantConditions = ["melanoma", "basal_cell_carcinoma", "squamous_cell_carcinoma"]
        
        if let topClassification = result.classifications.first,
           malignantConditions.contains(topClassification.label) {
            return topClassification.confidence > 0.8 ? .critical : .high
        }
        
        let highSeverityFindings = result.findings.filter { $0.severity == .high || $0.severity == .critical }
        if !highSeverityFindings.isEmpty {
            return .high
        }
        
        return result.confidence > 0.7 ? .medium : .low
    }
}

// MARK: - Analysis History Service

class AnalysisHistoryService {
    private let storageKey = "panderm_analysis_history"
    
    func loadAnalysisHistory() async throws -> [AnalysisResult] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        return try JSONDecoder().decode([AnalysisResult].self, from: data)
    }
    
    func saveAnalysis(_ analysis: AnalysisResult) async throws {
        var history = try await loadAnalysisHistory()
        history.insert(analysis, at: 0)
        
        // Keep only the last 500 analyses
        if history.count > 500 {
            history = Array(history.prefix(500))
        }
        
        let data = try JSONEncoder().encode(history)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func deleteAnalysis(_ analysisId: UUID) async throws {
        var history = try await loadAnalysisHistory()
        history.removeAll { $0.id == analysisId }
        
        let data = try JSONEncoder().encode(history)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func updateAnalysis(_ record: AnalysisRecord) async throws {
        // For now, this is a placeholder since we're working with AnalysisRecord vs AnalysisResult
        // In a full implementation, we'd need to convert back or maintain separate storage
    }
    
    func clearAllHistory() async throws {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

// MARK: - Supporting Types

enum ExportFormat: CaseIterable {
    case pdf
    case csv
    case json
    
    var displayName: String {
        switch self {
        case .pdf:
            return "PDF Report"
        case .csv:
            return "CSV Data"
        case .json:
            return "JSON Data"
        }
    }
}

enum DateRange: CaseIterable {
    case last30Days
    case last3Months
    case allTime
    
    var displayName: String {
        switch self {
        case .last30Days:
            return "Last 30 Days"
        case .last3Months:
            return "Last 3 Months"
        case .allTime:
            return "All Time"
        }
    }
}
import SwiftUI

struct AnalysisHistoryView: View {
    @StateObject private var viewModel = AnalysisHistoryViewModel()
    @State private var searchText = ""
    @State private var selectedAnalysis: AnalysisRecord?
    @State private var showingExportOptions = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Filter Options
                filterOptionsView
                
                // Analysis List
                List {
                    ForEach(filteredAnalyses) { analysis in
                        AnalysisHistoryRowView(analysis: analysis)
                            .onTapGesture {
                                selectedAnalysis = analysis
                            }
                    }
                    .onDelete(perform: deleteAnalyses)
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.refreshHistory()
                }
            }
            .navigationTitle("Analysis History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export All", action: exportAllData)
                        Button("Clear History", role: .destructive, action: clearHistory)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $selectedAnalysis) { analysis in
                AnalysisDetailView(analysis: analysis)
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView()
            }
        }
        .task {
            await viewModel.loadHistory()
        }
    }
    
    private var filterOptionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: viewModel.selectedFilter == .all) {
                    viewModel.selectedFilter = .all
                }
                
                FilterChip(title: "High Risk", isSelected: viewModel.selectedFilter == .highRisk) {
                    viewModel.selectedFilter = .highRisk
                }
                
                FilterChip(title: "Recent", isSelected: viewModel.selectedFilter == .recent) {
                    viewModel.selectedFilter = .recent
                }
                
                FilterChip(title: "Flagged", isSelected: viewModel.selectedFilter == .flagged) {
                    viewModel.selectedFilter = .flagged
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var filteredAnalyses: [AnalysisRecord] {
        var analyses = viewModel.filteredAnalyses
        
        if !searchText.isEmpty {
            analyses = analyses.filter { analysis in
                analysis.patientName?.localizedCaseInsensitiveContains(searchText) == true ||
                analysis.primaryDiagnosis.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return analyses
    }
    
    private func deleteAnalyses(offsets: IndexSet) {
        for index in offsets {
            let analysis = filteredAnalyses[index]
            viewModel.deleteAnalysis(analysis)
        }
    }
    
    private func exportAllData() {
        showingExportOptions = true
    }
    
    private func clearHistory() {
        viewModel.clearAllHistory()
    }
}

struct AnalysisHistoryRowView: View {
    let analysis: AnalysisRecord
    
    var body: some View {
        HStack {
            // Thumbnail
            AsyncImage(url: analysis.thumbnailURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(analysis.primaryDiagnosis.capitalized)
                    .font(.headline)
                    .lineLimit(1)
                
                if let patientName = analysis.patientName {
                    Text(patientName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    ConfidenceBadge(confidence: analysis.confidence)
                    
                    if analysis.isFlagged {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Text(analysis.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.tertiary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                RiskIndicator(level: analysis.riskLevel)
                
                if analysis.hasFollowUp {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ConfidenceBadge: View {
    let confidence: Double
    
    var body: some View {
        Text("\(Int(confidence * 100))%")
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        if confidence >= 0.8 {
            return .green.opacity(0.2)
        } else if confidence >= 0.6 {
            return .orange.opacity(0.2)
        } else {
            return .red.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct RiskIndicator: View {
    let level: RiskLevel
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
    }
    
    private var color: Color {
        switch level {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        case .critical:
            return .purple
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct AnalysisDetailView: View {
    let analysis: AnalysisRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Section
                    AsyncImage(url: analysis.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .cornerRadius(12)
                    
                    // Analysis Results
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Analysis Results")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            ResultRow(title: "Primary Diagnosis", value: analysis.primaryDiagnosis.capitalized)
                            ResultRow(title: "Confidence", value: "\(Int(analysis.confidence * 100))%")
                            ResultRow(title: "Risk Level", value: analysis.riskLevel.rawValue.capitalized)
                            if let patientName = analysis.patientName {
                                ResultRow(title: "Patient", value: patientName)
                            }
                            ResultRow(title: "Date", value: analysis.createdAt.formatted(date: .complete, time: .shortened))
                        }
                    }
                    
                    // Recommendations
                    if !analysis.recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommendations")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(analysis.recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                    Text(recommendation)
                                        .font(.body)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = analysis.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(notes)
                                .font(.body)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Analysis Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    Button("PDF Report") {
                        exportAsPDF()
                    }
                    
                    Button("CSV Data") {
                        exportAsCSV()
                    }
                    
                    Button("JSON Data") {
                        exportAsJSON()
                    }
                }
                
                Section(header: Text("Date Range")) {
                    Button("Last 30 Days") {
                        // Export last 30 days
                    }
                    
                    Button("Last 3 Months") {
                        // Export last 3 months
                    }
                    
                    Button("All Time") {
                        // Export all data
                    }
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportAsPDF() {
        // Implement PDF export
        dismiss()
    }
    
    private func exportAsCSV() {
        // Implement CSV export
        dismiss()
    }
    
    private func exportAsJSON() {
        // Implement JSON export
        dismiss()
    }
}

#Preview {
    AnalysisHistoryView()
}
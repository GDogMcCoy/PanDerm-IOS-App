import SwiftUI

struct ContentView: View {
    @StateObject private var inferenceManager = PanDermInferenceManager()
    
    var body: some View {
        TabView {
            // Main Analysis Tab
            NavigationView {
                ImageAnalysisView()
            }
            .tabItem {
                Label("Analyze", systemImage: "camera.fill")
            }
            
            // Patient List Tab
            NavigationView {
                PatientListView()
            }
            .tabItem {
                Label("Patients", systemImage: "person.3.fill")
            }
            
            // History Tab
            NavigationView {
                AnalysisHistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            
            // Settings Tab
            NavigationView {
                InferenceSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .environmentObject(inferenceManager)
        .onAppear {
            // Initialize the inference manager on app launch
            inferenceManager.initializeServices()
        }
    }
}

#Preview {
    ContentView()
} 
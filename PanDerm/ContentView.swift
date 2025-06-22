import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("PanDerm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Dermatology iOS App")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(spacing: 15) {
                    NavigationLink(destination: Text("Patient Management")) {
                        HStack {
                            Image(systemName: "person.2")
                            Text("Patient Management")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: Text("Skin Analysis")) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Skin Analysis")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: Text("Treatment Plans")) {
                        HStack {
                            Image(systemName: "list.clipboard")
                            Text("Treatment Plans")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("PanDerm")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
} 
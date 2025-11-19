import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            NewTaskView()
                .tabItem {
                    Label("New", systemImage: "plus.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(LiquidTheme.accent1)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LiquidBackground()
                
                Form {
                    Section(header: Text("API Configuration").foregroundColor(LiquidTheme.textSecondary)) {
                        SecureField("Gemini API Key", text: $viewModel.config.geminiKey)
                        SecureField("Deepseek API Key", text: $viewModel.config.deepseekKey)
                        SecureField("Grok API Key", text: $viewModel.config.grokKey)
                    }
                    .listRowBackground(Color.white.opacity(0.5))
                    .foregroundColor(LiquidTheme.textPrimary)
                    
                    Section(header: Text("About").foregroundColor(LiquidTheme.textSecondary)) {
                        Text("ElonAgent v1.1")
                            .foregroundColor(LiquidTheme.textSecondary)
                    }
                    .listRowBackground(Color.white.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}

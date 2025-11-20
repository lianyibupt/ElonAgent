import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isTestingGemini = false
    @State private var testAlertShown = false
    @State private var testMessage = ""
    
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

                    Section(header: Text("Diagnostics").foregroundColor(LiquidTheme.textSecondary)) {
                        HStack {
                            Button(action: {
                                isTestingGemini = true
                                testMessage = ""
                                Task {
                                    do {
                                        let result = try await LLMService.shared.performRequest(provider: .gemini, config: viewModel.config, prompt: "Hello from ElonAgent")
                                        testMessage = "Success\n\n" + result
                                    } catch {
                                        testMessage = "Failed: " + (error.localizedDescription)
                                    }
                                    isTestingGemini = false
                                    testAlertShown = true
                                }
                            }) {
                                Text(isTestingGemini ? "Testing Gemini..." : "Test Gemini")
                                    .foregroundColor(LiquidTheme.textPrimary)
                            }
                            Spacer()
                            if isTestingGemini {
                                ProgressView()
                            }
                        }
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
            .alert("Gemini Test", isPresented: $testAlertShown) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(testMessage)
            }
        }
    }
}

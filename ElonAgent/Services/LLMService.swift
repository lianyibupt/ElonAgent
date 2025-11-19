import Foundation

class LLMService {
    static let shared = LLMService()
    
    private init() {}
    
    func performRequest(provider: LLMProvider, config: LLMConfig, prompt: String) async throws -> String {
        let apiKey = getApiKey(for: provider, config: config)
        
        guard !apiKey.isEmpty else {
            throw NSError(domain: "LLMService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing API Key for \(provider.rawValue)"])
        }
        
        // In a real app, we would make the actual HTTP request here.
        // For this prototype, we will simulate a network delay and return a mock response.
        
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Sleep for 2 seconds
        
        return mockResponse(provider: provider, prompt: prompt)
    }
    
    private func getApiKey(for provider: LLMProvider, config: LLMConfig) -> String {
        switch provider {
        case .gemini: return config.geminiKey
        case .deepseek: return config.deepseekKey
        case .grok: return config.grokKey
        }
    }
    
    private func mockResponse(provider: LLMProvider, prompt: String) -> String {
        let responses = [
            "Analysis complete. The market trend indicates a bullish signal based on the provided indicators.",
            "Here is the summary: The stock shows strong resistance at the 50-day moving average.",
            "Processing request... Done. The sentiment analysis is positive.",
            "According to the latest data, the risk factors are minimal."
        ]
        return "[\(provider.rawValue)] Response to '\(prompt)':\n\n\(responses.randomElement() ?? "No data")"
    }
}

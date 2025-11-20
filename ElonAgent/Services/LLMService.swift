import Foundation

class LLMService {
    static let shared = LLMService()
    
    private init() {}
    
    func performRequest(provider: LLMProvider, config: LLMConfig, prompt: String) async throws -> String {
        let apiKey = getApiKey(for: provider, config: config)
        
        guard !apiKey.isEmpty else {
            throw NSError(domain: "LLMService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing API Key for \(provider.rawValue)"])
        }
        
        switch provider {
        case .gemini:
            let response = try await callGemini(apiKey: apiKey, prompt: prompt)
            return "[Real API] " + response
        case .deepseek:
            let response = try await callDeepseek(apiKey: apiKey, prompt: prompt)
            return "[Real API] " + response
        case .grok:
            let response = try await callGrok(apiKey: apiKey, prompt: prompt)
            return "[Real API] " + response
        }
    }
    
    private func getApiKey(for provider: LLMProvider, config: LLMConfig) -> String {
        switch provider {
        case .gemini: return config.geminiKey
        case .deepseek: return config.deepseekKey
        case .grok: return config.grokKey
        }
    }
    
    // MARK: - Gemini API
    private func callGemini(apiKey: String, prompt: String) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        let data = try await makeRequest(url: url, method: "POST", body: body, headers: ["x-goog-api-key": apiKey])
        if let text = try parseGeminiText(data: data) { return text }
        throw NSError(domain: "LLMService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Gemini response"])
    }
    
    // MARK: - Deepseek API
    private func callDeepseek(apiKey: String, prompt: String) async throws -> String {
        let urlString = "https://api.deepseek.com/chat/completions"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "stream": false
        ]
        
        let data = try await makeRequest(url: url, method: "POST", body: body, headers: ["Authorization": "Bearer \(apiKey)"])
        return try parseOpenAIStyleResponse(data: data)
    }
    
    // MARK: - Grok API
    private func callGrok(apiKey: String, prompt: String) async throws -> String {
        let urlString = "https://api.x.ai/v1/chat/completions"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let body: [String: Any] = [
            "model": "grok-beta",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "stream": false
        ]
        
        let data = try await makeRequest(url: url, method: "POST", body: body, headers: ["Authorization": "Bearer \(apiKey)"])
        return try parseOpenAIStyleResponse(data: data)
    }
    
    // MARK: - Helper Methods
    private func makeRequest(url: URL, method: String, body: [String: Any], headers: [String: String] = [:]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("API Error (\(httpResponse.statusCode)): \(errorMsg)")
            throw NSError(domain: "LLMService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorMsg)"])
        }
        
        return data
    }
    
    private func parseGeminiText(data: Data) throws -> String? {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let content = candidates.first?["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]] {
            for part in parts {
                if let text = part["text"] as? String { return text }
            }
        }
        return nil
    }

    private func parseOpenAIStyleResponse(data: Data) throws -> String {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        throw NSError(domain: "LLMService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse OpenAI-style response"])
    }
}

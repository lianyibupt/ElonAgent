import Foundation

enum LLMProvider: String, CaseIterable, Codable, Identifiable {
    case gemini = "Gemini"
    case deepseek = "Deepseek"
    case grok = "Grok"
    
    var id: String { self.rawValue }
}

enum TaskFrequency: String, CaseIterable, Codable, Identifiable {
    case daily = "Daily"
    case hourly = "Hourly"
    case minutely = "Every Minute" // For testing
    
    var id: String { self.rawValue }
}

struct TaskHistoryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var result: String
    var status: String // "Success", "Failed"
}

struct TaskItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var frequency: TaskFrequency
    var time: Date // For daily tasks
    var prompt: String
    var selectedProvider: LLMProvider
    var isEnabled: Bool = true
    var history: [TaskHistoryItem] = []
    var lastRun: Date?
}

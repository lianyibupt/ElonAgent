import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = [] {
        didSet { saveTasks() }
    }
    @Published var config: LLMConfig = LLMConfig() {
        didSet { saveConfig() }
    }
    
    private var timer: Timer?
    
    init() {
        loadData()
        startTimer()
    }
    
    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }
    
    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func toggleTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isEnabled.toggle()
        }
    }
    
    private func startTimer() {
        // Check every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkTasks()
            }
        }
    }
    
    private func checkTasks() async {
        let now = Date()
        for index in tasks.indices {
            var task = tasks[index]
            guard task.isEnabled else { continue }
            
            if shouldRun(task: task, now: now) {
                await runTask(at: index)
            }
        }
    }
    
    private func shouldRun(task: TaskItem, now: Date) -> Bool {
        guard let lastRun = task.lastRun else { return true }
        
        switch task.frequency {
        case .minutely:
            return now.timeIntervalSince(lastRun) >= 60
        case .hourly:
            return now.timeIntervalSince(lastRun) >= 3600
        case .daily:
            // Check if it's a different day and past the scheduled time
            let calendar = Calendar.current
            if !calendar.isDate(lastRun, inSameDayAs: now) {
                let taskTime = calendar.dateComponents([.hour, .minute], from: task.time)
                let nowTime = calendar.dateComponents([.hour, .minute], from: now)
                if (nowTime.hour! > taskTime.hour!) || (nowTime.hour! == taskTime.hour! && nowTime.minute! >= taskTime.minute!) {
                    return true
                }
            }
            return false
        }
    }
    
    func runTask(at index: Int) async {
        var task = tasks[index]
        let prompt = task.prompt
        let provider = task.selectedProvider
        
        do {
            let response = try await LLMService.shared.performRequest(provider: provider, config: config, prompt: prompt)
            let historyItem = TaskHistoryItem(date: Date(), result: response, status: "Success")
            task.history.insert(historyItem, at: 0)
            task.lastRun = Date()
        } catch {
            let historyItem = TaskHistoryItem(date: Date(), result: error.localizedDescription, status: "Failed")
            task.history.insert(historyItem, at: 0)
        }
        
        tasks[index] = task
    }
    
    // MARK: - Persistence
    private let tasksKey = "saved_tasks"
    private let configKey = "saved_config"
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func saveConfig() {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: configKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: configKey),
           let decoded = try? JSONDecoder().decode(LLMConfig.self, from: data) {
            config = decoded
        }
    }
}

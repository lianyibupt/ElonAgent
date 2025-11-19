import SwiftUI

struct TaskDetailView: View {
    @Binding var task: TaskItem
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(LiquidTheme.textPrimary)
                        
                        HStack {
                            Label(task.selectedProvider.rawValue, systemImage: "brain.head.profile")
                            Spacer()
                            Label(task.frequency.rawValue, systemImage: "clock.arrow.circlepath")
                        }
                        .foregroundColor(LiquidTheme.textSecondary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Prompt Section
                    VStack(alignment: .leading) {
                        Text("PROMPT")
                            .font(.caption)
                            .foregroundColor(LiquidTheme.textSecondary)
                        Text(task.prompt)
                            .font(.body)
                            .foregroundColor(LiquidTheme.textPrimary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // History Section
                    Text("HISTORY")
                        .font(.headline)
                        .foregroundColor(LiquidTheme.textPrimary)
                        .padding(.horizontal)
                    
                    if task.history.isEmpty {
                        Text("No history available yet.")
                            .foregroundColor(LiquidTheme.textSecondary)
                            .padding()
                    } else {
                        // Paging View for History
                        TabView {
                            ForEach(task.history) { item in
                                HistoryItemView(item: item)
                                    .padding()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 400) // Fixed height for paging area
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
                .foregroundColor(LiquidTheme.accent1)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NewTaskView(taskToEdit: task)
        }
    }
}

struct HistoryItemView: View {
    var item: TaskHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(LiquidTheme.textSecondary)
                Spacer()
                Text(item.status)
                    .font(.caption)
                    .foregroundColor(item.status == "Success" ? .green : .red)
            }
            
            ScrollView {
                Text(item.result)
                    .font(.body)
                    .foregroundColor(LiquidTheme.textPrimary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

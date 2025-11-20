import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LiquidBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.tasks.isEmpty {
                            emptyState
                        } else {
                            ForEach($viewModel.tasks) { $task in
                                ZStack {
                                    NavigationLink(destination: TaskDetailView(task: $task)) {
                                        LiquidTaskCard(task: task)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Prevents blue highlight
                                }
                                .padding(.horizontal)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                            viewModel.deleteTask(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.fill")
                .font(.system(size: 60))
                .foregroundColor(LiquidTheme.textSecondary.opacity(0.5))
            Text("No Active Tasks")
                .font(.title3)
                .foregroundColor(LiquidTheme.textPrimary)
            Text("Create a new task to start.")
                .font(.caption)
                .foregroundColor(LiquidTheme.textSecondary)
        }
        .padding(.top, 100)
    }
}

struct LiquidTaskCard: View {
    var task: TaskItem
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(LiquidTheme.textPrimary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { task.isEnabled },
                    set: { _ in viewModel.toggleTask(task) }
                ))
                .labelsHidden()
                .tint(LiquidTheme.accent1)
            }
            
            HStack {
                Label(task.selectedProvider.rawValue, systemImage: "brain.head.profile")
                Spacer()
                Label(task.frequency.rawValue, systemImage: "clock.arrow.circlepath")
            }
            .font(.caption)
            .foregroundColor(LiquidTheme.textSecondary)
            
            if let lastResult = task.history.first {
                Divider().background(Color.black.opacity(0.1))
                Text("Last Run: \(lastResult.status)")
                    .font(.caption2)
                    .foregroundColor(lastResult.status == "Success" ? .green : .red)
                Text(lastResult.result)
                    .font(.caption)
                    .foregroundColor(LiquidTheme.textSecondary)
                    .lineLimit(2)
            }
        }
        .liquidCardStyle()
    }
}

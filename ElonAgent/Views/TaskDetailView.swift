import SwiftUI
import Foundation

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
                .padding(.top)
                
                // Prompt Section (Collapsible or fixed height to save space)
                VStack(alignment: .leading) {
                    Text("PROMPT")
                        .font(.caption)
                        .foregroundColor(LiquidTheme.textSecondary)
                    ScrollView {
                        Text(task.prompt)
                            .font(.body)
                            .foregroundColor(LiquidTheme.textPrimary)
                            .padding()
                    }
                    .frame(height: 100) // Fixed height for prompt
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    LazyVStack(spacing: 16) {
                        ForEach(task.history) { item in
                            HistoryItemView(item: item)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                }
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
    enum MDBlock {
        case heading(Int, String)
        case list([String])
        case code(String?)
        case paragraph(String)
    }
    var blocks: [MDBlock] {
        let input = item.result.replacingOccurrences(of: "\r\n", with: "\n")
        var result: [MDBlock] = []
        var lines = input.components(separatedBy: "\n")
        var i = 0
        while i < lines.count {
            let line = lines[i]
            if line.hasPrefix("```") {
                let lang = line.replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1
                while i < lines.count, !lines[i].hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                result.append(.code(codeLines.joined(separator: "\n")))
                i += 1
                continue
            }
            let headingLevel = line.prefix(while: { $0 == "#" }).count
            if headingLevel > 0 {
                let text = String(line.drop(while: { $0 == "#" })).trimmingCharacters(in: .whitespaces)
                result.append(.heading(headingLevel, text))
                i += 1
                continue
            }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let firstToken = trimmed.split(separator: " ").first
            let isOrdered = firstToken.flatMap { Int($0) } != nil && trimmed.contains(".")
            if trimmed.hasPrefix("-") || trimmed.hasPrefix("*") || isOrdered {
                var items: [String] = []
                var j = i
                while j < lines.count {
                    let l = lines[j].trimmingCharacters(in: .whitespaces)
                    if l.hasPrefix("-") || l.hasPrefix("*") { items.append(l.dropFirst().trimmingCharacters(in: .whitespaces)) ; j += 1 ; continue }
                    if let first = l.split(separator: " ").first, Int(first) != nil, l.contains(".") {
                        let after = l.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                        items.append(after.count > 1 ? String(after[1]) : "")
                        j += 1
                        continue
                    }
                    break
                }
                result.append(.list(items))
                i = j
                continue
            }
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                i += 1
                continue
            }
            var paraLines: [String] = [line]
            var k = i + 1
            while k < lines.count {
                let l = lines[k]
                if l.trimmingCharacters(in: .whitespaces).isEmpty { break }
                if l.hasPrefix("```") || l.trimmingCharacters(in: .whitespaces).hasPrefix("-") || l.trimmingCharacters(in: .whitespaces).hasPrefix("*") || l.hasPrefix("#") { break }
                paraLines.append(l)
                k += 1
            }
            result.append(.paragraph(paraLines.joined(separator: "\n")))
            i = k
        }
        return result
    }
    
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
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                    switch block {
                    case .heading(let level, let text):
                        Text(text)
                            .font(level == 1 ? .title : (level == 2 ? .title2 : .headline))
                            .bold()
                            .foregroundColor(LiquidTheme.textPrimary)
                    case .list(let items):
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(items, id: \.self) { it in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("•")
                                    Text((try? AttributedString(markdown: it, options: .init(interpretedSyntax: .full))) ?? AttributedString(it))
                                }
                                .foregroundColor(LiquidTheme.textPrimary)
                            }
                        }
                    case .code(let code):
                        Text(code ?? "")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(LiquidTheme.textPrimary)
                            .padding(10)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                    case .paragraph(let text):
                        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
                        let hardBreakApplied = normalized.replacingOccurrences(of: "\n", with: "  \n")
                        let parsed = (try? AttributedString(markdown: hardBreakApplied, options: .init(interpretedSyntax: .full))) ?? AttributedString(text)
                        Text(parsed)
                            .foregroundColor(LiquidTheme.textPrimary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

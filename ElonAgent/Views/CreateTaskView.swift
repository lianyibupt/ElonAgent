import SwiftUI

struct NewTaskView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode // Used if presented as sheet, but here it's a tab
    
    // State for form fields
    @State private var title = ""
    @State private var frequency = TaskFrequency.daily
    @State private var time = Date()
    @State private var prompt = ""
    @State private var selectedProvider = LLMProvider.gemini
    
    // Edit Mode
    var taskToEdit: TaskItem?
    @State private var isEditing = false
    
    // Alert
    @State private var showingAlert = false
    
    // Focus State
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                LiquidBackground()
                    .onTapGesture {
                        isInputFocused = false
                    }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Input
                        VStack(alignment: .leading) {
                            Text("TASK TITLE")
                                .font(.caption)
                                .foregroundColor(LiquidTheme.textSecondary)
                            TextField("Enter title", text: $title)
                                .focused($isInputFocused)
                                .padding()
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(12)
                                .foregroundColor(LiquidTheme.textPrimary)
                        }
                        
                        // Frequency Picker
                        VStack(alignment: .leading) {
                            Text("FREQUENCY")
                                .font(.caption)
                                .foregroundColor(LiquidTheme.textSecondary)
                            Picker("Frequency", selection: $frequency) {
                                ForEach(TaskFrequency.allCases) { freq in
                                    Text(freq.rawValue).tag(freq)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        if frequency == .daily {
                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                .accentColor(LiquidTheme.accent1)
                        }
                        
                        // Provider Picker
                        VStack(alignment: .leading) {
                            Text("AI MODEL")
                                .font(.caption)
                                .foregroundColor(LiquidTheme.textSecondary)
                            Picker("Model", selection: $selectedProvider) {
                                ForEach(LLMProvider.allCases) { provider in
                                    Text(provider.rawValue).tag(provider)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Prompt Input
                        VStack(alignment: .leading) {
                            Text("PROMPT")
                                .font(.caption)
                                .foregroundColor(LiquidTheme.textSecondary)
                            TextEditor(text: $prompt)
                                .focused($isInputFocused)
                                .frame(height: 150)
                                .padding()
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(12)
                                .foregroundColor(LiquidTheme.textPrimary)
                        }
                        
                        Button(action: saveTask) {
                            Text(isEditing ? "Update Task" : "Create Task")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LiquidTheme.gradientPrimary)
                                .cornerRadius(16)
                                .shadow(color: LiquidTheme.accent1.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(title.isEmpty || prompt.isEmpty)
                        .opacity((title.isEmpty || prompt.isEmpty) ? 0.6 : 1)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .onAppear {
                if let task = taskToEdit {
                    isEditing = true
                    title = task.title
                    frequency = task.frequency
                    time = task.time
                    prompt = task.prompt
                    selectedProvider = task.selectedProvider
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Success"), message: Text(isEditing ? "Task updated successfully." : "Task created successfully."), dismissButton: .default(Text("OK")) {
                    if !isEditing {
                        // Reset form
                        title = ""
                        prompt = ""
                        isInputFocused = false // Dismiss keyboard
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isInputFocused = false
                    }
                }
            }
        }
    }
    
    private func saveTask() {
        isInputFocused = false // Dismiss keyboard immediately
        if isEditing, var task = taskToEdit {
            task.title = title
            task.frequency = frequency
            task.time = time
            task.prompt = prompt
            task.selectedProvider = selectedProvider
            viewModel.updateTask(task)
        } else {
            let newTask = TaskItem(
                title: title,
                frequency: frequency,
                time: time,
                prompt: prompt,
                selectedProvider: selectedProvider
            )
            viewModel.addTask(newTask)
        }
        showingAlert = true
    }
}

import SwiftUI

struct TasksListView: View {
    @StateObject private var viewModel: TaskViewModel
    @State private var showingAddTask = false
    @State private var selectedSegment = 0
    
    init() {
        _viewModel = StateObject(wrappedValue: TaskViewModel(networkService: NetworkService.shared))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                TasksSummaryRow(selectedSegment: $selectedSegment,
                                 allCount: viewModel.tasks.count,
                                 todayCount: viewModel.todayTasks.count,
                                 overdueCount: viewModel.overdueTasks.count,
                                 completedCount: viewModel.completedTasks.count)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Segment Control
                Picker("Filter", selection: $selectedSegment) {
                    Text("All").tag(0)
                    Text("Today").tag(1)
                    Text("Overdue").tag(2)
                    Text("Completed").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Task List
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Loading tasks...")
                } else if filteredTasksList.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle.fill",
                        title: "No Tasks",
                        message: "Add a task to get started"
                    )
                } else {
                    List {
                        ForEach(filteredTasksList) { task in
                            TaskRowView(task: task, viewModel: viewModel)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Tasks")
            .searchable(text: $viewModel.searchText, prompt: "Search tasks...")
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            })
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .onAppear {
                if viewModel.tasks.isEmpty {
                    viewModel.fetchTasks()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var filteredTasksList: [Task] {
        switch selectedSegment {
        case 1: return viewModel.todayTasks
        case 2: return viewModel.overdueTasks
        case 3: return viewModel.completedTasks
        default: return viewModel.filteredTasks
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasksList[index]
            viewModel.deleteTask(task)
        }
    }
}

private struct TasksSummaryRow: View {
    @Binding var selectedSegment: Int
    let allCount: Int
    let todayCount: Int
    let overdueCount: Int
    let completedCount: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                summaryButton(title: "All", count: allCount, color: .blue, tag: 0)
                summaryButton(title: "Today", count: todayCount, color: .orange, tag: 1)
                summaryButton(title: "Overdue", count: overdueCount, color: .red, tag: 2)
                summaryButton(title: "Completed", count: completedCount, color: .green, tag: 3)
            }
        }
    }
    
    @ViewBuilder
    private func summaryButton(title: String, count: Int, color: Color, tag: Int) -> some View {
        Button(action: { selectedSegment = tag }) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            .frame(width: 120, alignment: .leading)
            .background(selectedSegment == tag ? color.opacity(0.1) : Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedSegment == tag ? color : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 12) {
                // Checkbox
                Button(action: {
                    if task.status != .completed {
                        viewModel.markAsCompleted(task)
                    }
                }) {
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.status == .completed ? .green : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                // Priority Indicator
                Rectangle()
                    .fill(priorityColor(task.priority))
                    .frame(width: 4)
                    .cornerRadius(2)
                
                // Task Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.status == .completed)
                    
                    HStack(spacing: 8) {
                        Label(task.type.displayName, systemImage: task.type == .call ? "phone.fill" : "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let dueDate = task.dueDate {
                            Text(dueDate, style: .relative)
                                .font(.caption)
                                .foregroundColor(task.isOverdue ? .red : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Status Badge
                if task.isOverdue && task.status != .completed {
                    Text("Overdue")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                } else if task.isDueToday && task.status != .completed {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingDetail) {
            if #available(iOS 16.0, *) {
                TaskDetailView(task: task, viewModel: viewModel)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

@available(iOS 16.0, *)
struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingEdit = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 50))
                            .foregroundColor(task.status == .completed ? .green : .gray)
                        
                        Text(task.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(task.type.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Details
                    VStack(spacing: 16) {
                        if let description = task.description {
                            GroupBox(label: Label("Description", systemImage: "text.alignleft")) {
                                Text(description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        GroupBox(label: Label("Details", systemImage: "info.circle")) {
                            VStack(spacing: 12) {
                                DetailRow(label: "Status", value: task.status.displayName)
                                DetailRow(label: "Priority", value: task.priority.displayName)
                                
                                if let dueDate = task.dueDate {
                                    DetailRow(label: "Due Date", value: dueDate.formatted())
                                }
                                
                                if let completedDate = task.completedDate {
                                    DetailRow(label: "Completed", value: completedDate.formatted())
                                }
                            }
                        }
                        
                        if !task.tags.isEmpty {
                            GroupBox(label: Label("Tags", systemImage: "tag.fill")) {
                                FlowLayout(spacing: 8) {
                                    ForEach(task.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        if let notes = task.notes {
                            GroupBox(label: Label("Notes", systemImage: "note.text")) {
                                Text(notes)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEdit = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        if task.status != .completed {
                            Button(action: {
                                viewModel.markAsCompleted(task)
                                dismiss()
                            }) {
                                Label("Mark Complete", systemImage: "checkmark.circle")
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            viewModel.deleteTask(task)
                            dismiss()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            })
            .sheet(isPresented: $showingEdit) {
                EditTaskView(task: task, viewModel: viewModel)
            }
        }
    }
}

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var type: TaskType = .call
    @State private var priority: TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    TextField("Description (Optional)", text: $description)
                    
                    Picker("Type", selection: $type) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                }
                
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            })
        }
    }
    
    private func saveTask() {
        let task = Task(
            id: UUID().uuidString,
            createdAt: Date(),
            updatedAt: Date(),
            title: title,
            description: description.isEmpty ? nil : description,
            type: type,
            status: .pending,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            completedDate: nil,
            reminderDate: nil,
            assignedTo: nil,
            assignedBy: nil,
            leadId: nil,
            clientId: nil,
            projectId: nil,
            propertyId: nil,
            tags: [],
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.createTask(task)
        dismiss()
    }
}

struct EditTaskView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var type: TaskType
    @State private var status: TaskStatus
    @State private var priority: TaskPriority
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var notes: String
    
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
        _type = State(initialValue: task.type)
        _status = State(initialValue: task.status)
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _notes = State(initialValue: task.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    Picker("Type", selection: $type) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                }
                
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            })
        }
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.description = description.isEmpty ? nil : description
        updatedTask.type = type
        updatedTask.status = status
        updatedTask.priority = priority
        updatedTask.dueDate = hasDueDate ? dueDate : nil
        updatedTask.notes = notes.isEmpty ? nil : notes
        updatedTask.updatedAt = Date()
        
        if status == .completed && task.status != .completed {
            updatedTask.completedDate = Date()
        }
        
        viewModel.updateTask(updatedTask)
        dismiss()
    }
}

// FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    @available(iOS 16.0, *)
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    @available(iOS 16.0, *)
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: ProposedViewSize(result.frames[index].size))
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

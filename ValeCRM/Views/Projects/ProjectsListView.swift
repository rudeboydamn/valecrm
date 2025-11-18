import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject var viewModel: RehabProjectViewModel
    @State private var showingAddProject = false
    @State private var selectedProject: RehabProject?
    
    var body: some View {
        NavigationView {
            VStack {
                // Project Summary Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ProjectMetricCard(
                            title: "Total Budget",
                            value: "$\(viewModel.totalBudget, default: "%.0f")",
                            icon: "dollarsign.circle.fill",
                            color: .blue
                        )
                        
                        ProjectMetricCard(
                            title: "Total Spent",
                            value: "$\(viewModel.totalSpent, default: "%.0f")",
                            icon: "arrow.down.circle.fill",
                            color: .orange
                        )
                        
                        ProjectMetricCard(
                            title: "Remaining",
                            value: "$\(viewModel.totalRemaining, default: "%.0f")",
                            icon: "banknote.fill",
                            color: .green
                        )
                        
                        ProjectMetricCard(
                            title: "Avg Utilization",
                            value: "\(viewModel.averageBudgetUtilization, default: "%.1f")%",
                            icon: "chart.pie.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Projects List
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.projects.isEmpty {
                    EmptyStateView(
                        icon: "hammer.fill",
                        title: "No Projects Yet",
                        message: "Tap the + button to add your first rehab project"
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredProjects) { project in
                            ProjectRowView(project: project)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedProject = project
                                }
                        }
                    }
                }
            }
            .navigationTitle("Rehab Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProject = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.fetchProjects) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedProject) { project in
                ProjectDetailView(project: project)
                    .environmentObject(viewModel)
            }
            .onAppear {
                if viewModel.projects.isEmpty {
                    viewModel.fetchProjects()
                }
            }
        }
    }
}

struct ProjectMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 150)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ProjectRowView: View {
    let project: RehabProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.displayName)
                    .font(.headline)
                Spacer()
                ProjectStatusBadge(status: project.status)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(project.totalBudget, default: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(project.totalSpent, default: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(project.remainingBudget, default: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(project.remainingBudget > 0 ? .green : .red)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(progressColor(for: project.budgetUtilization))
                        .frame(width: geometry.size.width * CGFloat(min(project.budgetUtilization / 100, 1.0)), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("\(project.budgetUtilization, default: "%.1f")% utilized")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func progressColor(for utilization: Double) -> Color {
        switch utilization {
        case 0..<50:
            return .green
        case 50..<80:
            return .orange
        default:
            return .red
        }
    }
}

struct ProjectStatusBadge: View {
    let status: String?
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    private var statusColor: Color {
        guard let status = status?.lowercased() else { return .gray }
        if status.contains("planning") { return .blue }
        if status.contains("active") { return .green }
        if status.contains("hold") { return .orange }
        if status.contains("completed") { return .purple }
        if status.contains("cancelled") { return .red }
        return .gray
    }
    
    private var statusText: String {
        status?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Unknown"
    }
}

struct AddProjectView: View {
    @EnvironmentObject var viewModel: RehabProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var propertyAddress = ""
    @State private var propertyName = ""
    @State private var status: String = ProjectStatus.planning.rawValue
    @State private var totalBudget = ""
    @State private var totalRehabCosts = ""
    @State private var startDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Information")) {
                    TextField("Property Name", text: $propertyName)
                    TextField("Property Address", text: $propertyAddress)
                    
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { statusCase in
                            Text(statusCase.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .tag(statusCase.rawValue)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }
                
                Section(header: Text("Budget")) {
                    TextField("Total Purchase / Holding Budget", text: $totalBudget)
                        .keyboardType(.decimalPad)
                    
                    TextField("Total Rehab Costs", text: $totalRehabCosts)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Project")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveProject()
                }
                .disabled(!isFormValid)
            )
        }
    }
    
    private var isFormValid: Bool {
        !propertyAddress.isEmpty && !totalBudget.isEmpty
    }
    
    private func saveProject() {
        var project = RehabProject()
        project.propertyName = propertyName
        project.propertyAddress = propertyAddress
        project.status = status
        project.purchaseDate = isoFormatter.string(from: startDate)
        project.totalPurchaseCosts = Double(totalBudget)
        project.totalRehabCosts = Double(totalRehabCosts)
        
        viewModel.createProject(project)
        presentationMode.wrappedValue.dismiss()
    }
    
    private var isoFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

struct ProjectDetailView: View {
    let project: RehabProject
    @EnvironmentObject var viewModel: RehabProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Project Information")) {
                    DetailRow(label: "Property", value: project.displayName)
                    HStack {
                        Text("Status")
                            .foregroundColor(.secondary)
                        Spacer()
                        ProjectStatusBadge(status: project.status)
                    }
                }
                
                Section(header: Text("Timeline")) {
                    if let startDate = project.startDate {
                        DetailRow(label: "Start Date", value: startDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let completionDate = project.completionDate {
                        DetailRow(label: "Completion Date", value: completionDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
                
                Section(header: Text("Budget")) {
                    DetailRow(label: "Total Budget", value: "$\(project.totalBudget, default: "%.0f")")
                    DetailRow(label: "Spent Amount", value: "$\(project.totalSpent, default: "%.0f")")
                    DetailRow(label: "Remaining", value: "$\(project.remainingBudget, default: "%.0f")")
                    DetailRow(label: "Utilization", value: "\(project.budgetUtilization, default: "%.1f")%")
                }
            }
            .navigationTitle("Project Details")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

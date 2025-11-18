import Foundation
import Combine

final class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedStatus: TaskStatus?
    @Published var selectedPriority: TaskPriority?
    @Published var showOnlyOverdue = false
    @Published var showOnlyDueToday = false
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            let matchesSearch = searchText.isEmpty ||
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesStatus = selectedStatus == nil || task.status == selectedStatus
            let matchesPriority = selectedPriority == nil || task.priority == selectedPriority
            let matchesOverdue = !showOnlyOverdue || task.isOverdue
            let matchesDueToday = !showOnlyDueToday || task.isDueToday
            
            return matchesSearch && matchesStatus && matchesPriority && matchesOverdue && matchesDueToday
        }
    }
    
    var pendingTasks: [Task] {
        tasks.filter { $0.status == .pending || $0.status == .inProgress }
    }
    
    var overdueTasks: [Task] {
        tasks.filter { $0.isOverdue }
    }
    
    var todayTasks: [Task] {
        tasks.filter { $0.isDueToday }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.status == .completed }
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchTasks() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchTasks()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] tasks in
                self?.tasks = tasks
            })
            .store(in: &cancellables)
    }
    
    func createTask(_ task: Task) {
        isLoading = true
        errorMessage = nil
        
        networkService.createTask(task)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] task in
                self?.tasks.insert(task, at: 0)
            })
            .store(in: &cancellables)
    }
    
    func updateTask(_ task: Task) {
        isLoading = true
        errorMessage = nil
        
        networkService.updateTask(task)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedTask in
                if let index = self?.tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                    self?.tasks[index] = updatedTask
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteTask(_ task: Task) {
        isLoading = true
        errorMessage = nil
        
        networkService.deleteTask(id: task.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.tasks.removeAll { $0.id == task.id }
            })
            .store(in: &cancellables)
    }
    
    func markAsCompleted(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .completed
        updatedTask.completedDate = Date()
        updateTask(updatedTask)
    }
    
    func clearFilters() {
        selectedStatus = nil
        selectedPriority = nil
        showOnlyOverdue = false
        showOnlyDueToday = false
        searchText = ""
    }
}

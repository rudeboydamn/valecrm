import Foundation
import Combine

final class RehabProjectViewModel: ObservableObject {
    @Published var projects: [RehabProject] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: String?
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    var filteredProjects: [RehabProject] {
        guard let status = selectedStatus else { return projects }
        return projects.filter { $0.status == status }
    }
    
    var activeProjects: [RehabProject] {
        projects.filter { $0.status == "active" || $0.status == "Active" }
    }
    
    var totalBudget: Double {
        projects.reduce(0) { $0 + $1.totalBudget }
    }
    
    var totalSpent: Double {
        projects.reduce(0) { $0 + $1.totalSpent }
    }
    
    var totalRemaining: Double {
        projects.reduce(0) { $0 + $1.remainingBudget }
    }
    
    var totalInvestment: Double {
        projects.compactMap { $0.totalInvestment }.reduce(0, +)
    }
    
    var totalNetIncome: Double {
        projects.compactMap { $0.netIncome }.reduce(0, +)
    }
    
    var averageBudgetUtilization: Double {
        let utilizations = projects.map { $0.budgetUtilization }.filter { $0 > 0 }
        guard !utilizations.isEmpty else { return 0 }
        return utilizations.reduce(0, +) / Double(utilizations.count)
    }
    
    var averageROI: Double {
        let rois = projects.compactMap { $0.roi }.filter { $0 > 0 }
        guard !rois.isEmpty else { return 0 }
        return rois.reduce(0, +) / Double(rois.count)
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchProjects() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchProjects()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] projects in
                self?.projects = projects
            })
            .store(in: &cancellables)
    }
    
    func createProject(_ project: RehabProject) {
        isLoading = true
        errorMessage = nil
        
        networkService.createProject(project)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] newProject in
                self?.projects.append(newProject)
            })
            .store(in: &cancellables)
    }
    
    func updateProject(_ project: RehabProject) {
        isLoading = true
        errorMessage = nil
        
        networkService.updateProject(project)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedProject in
                if let index = self?.projects.firstIndex(where: { $0.id == updatedProject.id }) {
                    self?.projects[index] = updatedProject
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteProject(_ project: RehabProject) {
        isLoading = true
        errorMessage = nil
        
        networkService.deleteProject(id: project.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.projects.removeAll { $0.id == project.id }
            })
            .store(in: &cancellables)
    }
    
    func clearFilter() {
        selectedStatus = nil
    }
}

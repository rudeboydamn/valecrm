import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var metrics: ReportDashboardMetrics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefresh: Date?
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchMetrics() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchDashboardMetrics()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] metrics in
                self?.metrics = metrics
                self?.lastRefresh = Date()
            })
            .store(in: &cancellables)
    }
    
    func refresh() {
        fetchMetrics()
    }
}

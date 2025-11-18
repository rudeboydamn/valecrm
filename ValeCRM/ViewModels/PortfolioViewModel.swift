import Foundation
import Combine

final class PortfolioViewModel: ObservableObject {
    @Published var dashboardMetrics: PortfolioDashboardMetrics?
    @Published var properties: [Property] = []
    @Published var units: [Unit] = []
    @Published var residents: [Resident] = []
    @Published var leases: [Lease] = []
    @Published var mortgages: [Mortgage] = []
    @Published var expenses: [Expense] = []
    @Published var payments: [Payment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPortfolioData() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchPortfolio()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.dashboardMetrics = response.data.dashboard
                self?.properties = response.data.properties
                self?.units = response.data.units
                self?.residents = response.data.residents
                self?.leases = response.data.leases
                self?.mortgages = response.data.mortgages
                self?.expenses = response.data.expenses
                self?.payments = response.data.payments
            })
            .store(in: &cancellables)
    }
    
    // Helper computed properties
    var totalProperties: Int {
        properties.count
    }
    
    var occupiedUnits: Int {
        residents.count
    }
    
    var totalUnits: Int {
        dashboardMetrics?.totalUnits ?? 0
    }
    
    var occupancyRate: Double {
        dashboardMetrics?.occupancyRate ?? 0
    }
    
    var currentMonthPayments: [Payment] {
        let calendar = Calendar.current
        let now = Date()
        
        return payments.filter { payment in
            guard let dueDate = ISO8601DateFormatter().date(from: payment.dueDate) else {
                return false
            }
            return calendar.isDate(dueDate, equalTo: now, toGranularity: .month)
        }
    }
    
    var paidPayments: [Payment] {
        currentMonthPayments.filter { $0.status == "paid" }
    }
    
    var unpaidPayments: [Payment] {
        currentMonthPayments.filter { $0.status != "paid" }
    }
}

import Foundation
import Combine
import Supabase

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
    
    private let propertyService = PropertyDatabaseService.shared
    private let supabase = SupabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    func fetchPortfolioData() {
        _Concurrency.Task {
            await MainActor.run { self.isLoading = true }
            
            do {
                // Fetch properties
                let fetchedProperties = try await propertyService.fetchAll()
                
                // Fetch portfolio dashboard metrics via PropertyDatabaseService
                let dashboard = try await propertyService.fetchPortfolioDashboard()
                
                // Fetch related entities
                let unitsQuery = supabase.from("units")
                    .select()
                let unitsResponse: PostgrestResponse<[Unit]> = try await unitsQuery.execute()
                let fetchedUnits = unitsResponse.value
                
                let residentsQuery = supabase.from("residents")
                    .select()
                let residentsResponse: PostgrestResponse<[Resident]> = try await residentsQuery.execute()
                let fetchedResidents = residentsResponse.value
                
                let leasesQuery = supabase.from("leases")
                    .select()
                let leasesResponse: PostgrestResponse<[Lease]> = try await leasesQuery.execute()
                let fetchedLeases = leasesResponse.value
                
                let mortgagesQuery = supabase.from("mortgages")
                    .select()
                let mortgagesResponse: PostgrestResponse<[Mortgage]> = try await mortgagesQuery.execute()
                let fetchedMortgages = mortgagesResponse.value
                
                let expensesQuery = supabase.from("expenses")
                    .select()
                let expensesResponse: PostgrestResponse<[Expense]> = try await expensesQuery.execute()
                let fetchedExpenses = expensesResponse.value
                
                let paymentsQuery = supabase.from("payments")
                    .select()
                let paymentsResponse: PostgrestResponse<[Payment]> = try await paymentsQuery.execute()
                let fetchedPayments = paymentsResponse.value
                
                await MainActor.run {
                    self.dashboardMetrics = dashboard
                    self.properties = fetchedProperties
                    self.units = fetchedUnits
                    self.residents = fetchedResidents
                    self.leases = fetchedLeases
                    self.mortgages = fetchedMortgages
                    self.expenses = fetchedExpenses
                    self.payments = fetchedPayments
                    self.isLoading = false
                    self.errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = SupabaseError.map(error).localizedDescription
                    self.isLoading = false
                }
            }
        }
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

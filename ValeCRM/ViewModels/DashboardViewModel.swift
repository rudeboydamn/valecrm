import Foundation
import Combine
import Supabase

final class DashboardViewModel: ObservableObject {
    @Published var metrics: ReportDashboardMetrics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefresh: Date?
    
    private let supabase = SupabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    func fetchMetrics() {
        _Concurrency.Task {
            await MainActor.run { self.isLoading = true }
            
            do {
                // Fetch dashboard metrics via RPC
                let query = try supabase.client
                    .rpc("get_dashboard_metrics")
                let response: PostgrestResponse<ReportDashboardMetrics> = try await query.execute()
                let value = response.value
                
                await MainActor.run {
                    self.metrics = value
                    self.lastRefresh = Date()
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
    
    func refresh() {
        fetchMetrics()
    }
}

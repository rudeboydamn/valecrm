import Foundation
import Supabase

/// Database service for Property operations
final class PropertyDatabaseService: BaseDatabaseService<Property> {
    static let shared = PropertyDatabaseService()
    
    private init() {
        super.init(tableName: "properties")
    }
    
    /// Search properties by address or city
    func search(query: String) async throws -> [Property] {
        do {
            let queryBuilder = supabase.from(tableName)
                .select()
                .or("address.ilike.%\(query)%,city.ilike.%\(query)%,state.ilike.%\(query)%")
            let response: PostgrestResponse<[Property]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Filter properties by type
    func fetchByType(_ type: PropertyType) async throws -> [Property] {
        do {
            let queryBuilder = supabase.from(tableName)
                .select()
                .eq("property_type", value: type.rawValue)
            let response: PostgrestResponse<[Property]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Filter properties by status
    func fetchByStatus(_ status: PropertyStatus) async throws -> [Property] {
        do {
            let queryBuilder = supabase.from(tableName)
                .select()
                .eq("status", value: status.rawValue)
            let response: PostgrestResponse<[Property]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Fetch portfolio dashboard metrics
    func fetchPortfolioDashboard() async throws -> PortfolioDashboardMetrics {
        do {
            // This would typically be a database function or RPC call
            let query = try supabase.client
                .rpc("get_portfolio_dashboard")
            let response: PostgrestResponse<PortfolioDashboardMetrics> = try await query.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Fetch properties with units
    func fetchWithUnits() async throws -> [(Property, [Unit])] {
        do {
            // Fetch properties
            let properties: [Property] = try await fetchAll()
            
            // Fetch units for each property
            var result: [(Property, [Unit])] = []
            
            for property in properties {
                let unitsQuery = supabase.from("units")
                    .select()
                    .eq("property_id", value: property.id)
                let unitsResponse: PostgrestResponse<[Unit]> = try await unitsQuery.execute()
                let units = unitsResponse.value
                
                result.append((property, units))
            }
            
            return result
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Calculate total portfolio value
    func calculateTotalValue() async throws -> Double {
        do {
            let properties = try await fetchAll()
            return properties.reduce(0) { $0 + ($1.currentValue ?? $1.purchasePrice ?? 0) }
        } catch {
            throw SupabaseError.map(error)
        }
    }
}

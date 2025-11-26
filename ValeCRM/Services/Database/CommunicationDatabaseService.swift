import Foundation
import Supabase

/// Database service for Communication operations
final class CommunicationDatabaseService: BaseDatabaseService<Communication> {
    static let shared = CommunicationDatabaseService()
    
    private init() {
        super.init(tableName: "communications")
    }
    
    /// Search communications by subject or notes
    func search(query: String) async throws -> [Communication] {
        do {
            let queryBuilder = supabase.from(tableName)
                .select()
                .or("subject.ilike.%\(query)%,notes.ilike.%\(query)%")
                .order("communication_date", ascending: false)
            let response: PostgrestResponse<[Communication]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Filter communications by type
    func fetchByType(_ type: CommunicationType) async throws -> [Communication] {
        do {
            let queryBuilder = supabase.from(tableName)
                .select()
                .eq("type", value: type.rawValue)
                .order("communication_date", ascending: false)
            let response: PostgrestResponse<[Communication]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Fetch communications by contact/client ID
    func fetchByContact(contactId: String) async throws -> [Communication] {
        do {
            let queryBuilder = supabase.from(tableName)
                .select()
                .eq("contact_id", value: contactId)
                .order("communication_date", ascending: false)
            let response: PostgrestResponse<[Communication]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Fetch recent communications (last 30 days)
    func fetchRecent() async throws -> [Communication] {
        do {
            let formatter = ISO8601DateFormatter()
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            
            let queryBuilder = supabase.from(tableName)
                .select()
                .gte("communication_date", value: formatter.string(from: thirtyDaysAgo))
                .order("communication_date", ascending: false)
            let response: PostgrestResponse<[Communication]> = try await queryBuilder.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
}

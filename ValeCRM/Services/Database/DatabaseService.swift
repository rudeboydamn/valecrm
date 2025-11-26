import Foundation
import Supabase

/// Base protocol for database operations with common CRUD methods
protocol DatabaseServiceProtocol {
    associatedtype Entity: Codable & Identifiable where Entity.ID == UUID
    
    var tableName: String { get }
    var supabase: SupabaseManager { get }
    
    func fetchAll() async throws -> [Entity]
    func fetch(id: UUID) async throws -> Entity?
    func create(_ entity: Entity) async throws -> Entity
    func update(_ entity: Entity) async throws -> Entity
    func delete(id: UUID) async throws
    func search(query: String) async throws -> [Entity]
}

/// Base database service with common CRUD implementations
class BaseDatabaseService<T: Codable & Identifiable> where T.ID: CustomStringConvertible & Codable {
    let tableName: String
    let supabase: SupabaseManager
    
    init(tableName: String, supabase: SupabaseManager = .shared) {
        self.tableName = tableName
        self.supabase = supabase
    }
    
    /// Convert ID to string for database queries
    private func idToString(_ id: T.ID) -> String {
        String(describing: id)
    }
    
    /// Fetch all records
    func fetchAll() async throws -> [T] {
        do {
            let query = supabase.client
                .from(tableName)
                .select()
                .order("created_at", ascending: false)
            let response: PostgrestResponse<[T]> = try await query.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Fetch record by ID
    func fetch(id: T.ID) async throws -> T? {
        do {
            let query = supabase.client
                .from(tableName)
                .select()
                .eq("id", value: idToString(id))
                .limit(1)
            let response: PostgrestResponse<[T]> = try await query.execute()
            let value = response.value
            
            return value.first
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Create new record
    func create(_ entity: T) async throws -> T {
        do {
            let query = try supabase.client
                .from(tableName)
                .insert(entity)
                .select()
            let response: PostgrestResponse<[T]> = try await query.execute()
            let value = response.value
            
            guard let created = value.first else {
                throw SupabaseError.databaseError("Failed to create record")
            }
            
            return created
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Update existing record
    func update(_ entity: T) async throws -> T {
        do {
            let query = try supabase.client
                .from(tableName)
                .update(entity)
                .eq("id", value: idToString(entity.id))
                .select()
            let response: PostgrestResponse<[T]> = try await query.execute()
            let value = response.value
            
            guard let updated = value.first else {
                throw SupabaseError.databaseError("Failed to update record")
            }
            
            return updated
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Delete record by ID
    func delete(id: T.ID) async throws {
        do {
            let query = supabase.client
                .from(tableName)
                .delete()
                .eq("id", value: idToString(id))
            _ = try await query.execute()
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Fetch with pagination
    func fetchPaginated(limit: Int = 20, offset: Int = 0) async throws -> [T] {
        do {
            let query = supabase.client
                .from(tableName)
                .select()
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
            let response: PostgrestResponse<[T]> = try await query.execute()
            let value = response.value
            
            return value
        } catch {
            throw SupabaseError.map(error)
        }
    }
    
    /// Count total records
    func count() async throws -> Int {
        do {
            let query = supabase.client
                .from(tableName)
                .select("*", head: true, count: .exact)
            let response = try await query.execute()
            
            return response.count ?? 0
        } catch {
            throw SupabaseError.map(error)
        }
    }
}

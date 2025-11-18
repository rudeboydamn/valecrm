import Foundation
import Combine
import SwiftUI

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case serverError(Int, String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided."
        case .unauthorized:
            return "Authentication failed or token expired."
        case .noData:
            return "No data returned from server."
        case .decodingError:
            return "Failed to decode server response."
        case .networkError(let message):
            return message
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        }
    }
}

// MARK: - API Response Models

struct PortfolioResponse: Codable {
    let success: Bool
    let data: PortfolioData
}

struct PortfolioData: Codable {
    let dashboard: PortfolioDashboardMetrics
    let properties: [Property]
    let units: [Unit]
    let residents: [Resident]
    let leases: [Lease]
    let mortgages: [Mortgage]
    let expenses: [Expense]
    let payments: [Payment]
}

struct PortfolioDashboardMetrics: Codable {
    let totalRentDue: Double
    let totalRentCollected: Double
    let totalUnits: Int
    let occupiedUnits: Int
    let occupancyRate: Double
    let residentsPaid: Int
    let collectionRate: Double
    let totalPortfolioValue: Double
    let totalMonthlyIncome: Double
    let totalMonthlyExpenses: Double
    let netMonthlyCashFlow: Double
}

struct PropertiesResponse: Codable {
    let success: Bool
    let data: [Property]
}

struct PropertyDetailResponse: Codable {
    let success: Bool
    let data: PropertyDetail
}

struct PropertyDetail: Codable {
    let id: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let propertyType: String
    let totalUnits: Int
    let purchasePrice: Double?
    let marketValue: Double?
    let propertyTaxAnnual: Double?
    let insuranceAnnual: Double?
    let hoaMonthly: Double?
    let units: [Unit]
    let mortgage: Mortgage?
    let expenses: [Expense]
}

struct Unit: Codable {
    let id: String
    let propertyId: String
    let unitNumber: String?
    let bedrooms: Int?
    let bathrooms: Double?
    let monthlyRent: Double?
    let status: String
}

struct Resident: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String?
    let unitId: String
    let status: String
    let moveInDate: String?
    let moveOutDate: String?
}

struct Lease: Codable {
    let id: String
    let tenantId: String
    let unitId: String
    let startDate: String
    let endDate: String
    let monthlyRent: Double
    let status: String
}

struct Mortgage: Codable {
    let id: String
    let propertyId: String
    let lenderName: String?
    let monthlyPayment: Double
    let interestRate: Double?
    let status: String
}

struct Expense: Codable {
    let id: String
    let propertyId: String
    let expenseDate: String
    let category: String
    let description: String
    let amount: Double
    let isRecurring: Bool?
}

struct Payment: Codable {
    let id: String
    let tenantId: String
    let leaseId: String
    let dueDate: String
    let amountDue: Double
    let amountPaid: Double?
    let paymentDate: String?
    let paymentMethod: String?
    let status: String
}

struct ProjectsResponse: Codable {
    let success: Bool
    let data: [RehabProject]
}

struct ProjectDetailResponse: Codable {
    let success: Bool
    let data: RehabProject
}

final class NetworkService: ObservableObject {
    static let shared = NetworkService()

    private let baseURL: URL
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private var jwtToken: String?

    init() {
        self.baseURL = AppConfig.apiURL
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder = decoder
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        jsonEncoder = encoder
    }

    func setAuthToken(_ token: String?) {
        self.jwtToken = token
    }
    
    func request<T: Decodable>(from endpoint: String,
                               method: String = "GET",
                               body: Data? = nil) -> AnyPublisher<T, APIError> {
        performRequest(from: endpoint, method: method, body: body)
            .tryMap { data -> T in
                guard !data.isEmpty else { throw APIError.noData }
                return try self.jsonDecoder.decode(T.self, from: data)
            }
            .mapError { error in
                if let apiError = error as? APIError { return apiError }
                if error is DecodingError { return .decodingError }
                return .networkError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Typed API Methods for Leads
    
    func fetchLeads() -> AnyPublisher<[Lead], APIError> {
        return request(from: "/api/leads", method: "GET")
    }
    
    func createLead(_ lead: Lead) -> AnyPublisher<Lead, APIError> {
        guard let body = try? jsonEncoder.encode(lead) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/leads", method: "POST", body: body)
    }
    
    func updateLead(_ lead: Lead) -> AnyPublisher<Lead, APIError> {
        guard let body = try? jsonEncoder.encode(lead) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/leads/\(lead.id)", method: "PATCH", body: body)
    }
    
    func deleteLead(id: UUID) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/leads/\(id.uuidString)", method: "DELETE")
    }
    
    // MARK: - Portfolio API Methods
    
    func fetchPortfolio() -> AnyPublisher<PortfolioResponse, APIError> {
        return request(from: "/api/portfolio", method: "GET")
    }
    
    func fetchProperties() -> AnyPublisher<[Property], APIError> {
        return request(from: "/api/portfolio/properties", method: "GET")
            .map { (response: PropertiesResponse) in response.data }
            .eraseToAnyPublisher()
    }
    
    func fetchProperty(id: String) -> AnyPublisher<PropertyDetail, APIError> {
        return request(from: "/api/portfolio/properties?id=\(id)", method: "GET")
            .map { (response: PropertyDetailResponse) in response.data }
            .eraseToAnyPublisher()
    }
    
    func createProperty(_ property: Property) -> AnyPublisher<Property, APIError> {
        guard let body = try? jsonEncoder.encode(property) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/portfolio/properties", method: "POST", body: body)
    }
    
    func updateProperty(_ property: Property) -> AnyPublisher<Property, APIError> {
        guard let body = try? jsonEncoder.encode(property) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/portfolio/properties", method: "PUT", body: body)
    }
    
    func deleteProperty(id: String) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/portfolio/properties?id=\(id)", method: "DELETE")
    }
    
    // MARK: - Projects API Methods
    
    func fetchProjects() -> AnyPublisher<[RehabProject], APIError> {
        return request(from: "/api/projects", method: "GET")
            .map { (response: ProjectsResponse) in response.data }
            .eraseToAnyPublisher()
    }
    
    func fetchProject(id: String) -> AnyPublisher<RehabProject, APIError> {
        return request(from: "/api/projects?id=\(id)", method: "GET")
            .map { (response: ProjectDetailResponse) in response.data }
            .eraseToAnyPublisher()
    }
    
    func createProject(_ project: RehabProject) -> AnyPublisher<RehabProject, APIError> {
        guard let body = try? jsonEncoder.encode(project) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/projects", method: "POST", body: body)
    }
    
    func updateProject(_ project: RehabProject) -> AnyPublisher<RehabProject, APIError> {
        guard let body = try? jsonEncoder.encode(project) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/projects", method: "PUT", body: body)
    }
    
    func deleteProject(id: String) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/projects?id=\(id)", method: "DELETE")
    }
    
    // MARK: - Clients API Methods
    
    func fetchClients() -> AnyPublisher<[Client], APIError> {
        return request(from: "/api/clients", method: "GET")
    }
    
    func fetchClient(id: String) -> AnyPublisher<Client, APIError> {
        return request(from: "/api/clients/\(id)", method: "GET")
    }
    
    func createClient(_ client: Client) -> AnyPublisher<Client, APIError> {
        guard let body = try? jsonEncoder.encode(client) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/clients", method: "POST", body: body)
    }
    
    func updateClient(_ client: Client) -> AnyPublisher<Client, APIError> {
        guard let body = try? jsonEncoder.encode(client) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/clients/\(client.id)", method: "PUT", body: body)
    }
    
    func deleteClient(id: String) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/clients/\(id)", method: "DELETE")
    }
    
    // MARK: - Tasks API Methods
    
    func fetchTasks() -> AnyPublisher<[Task], APIError> {
        return request(from: "/api/tasks", method: "GET")
    }
    
    func fetchTask(id: String) -> AnyPublisher<Task, APIError> {
        return request(from: "/api/tasks/\(id)", method: "GET")
    }
    
    func createTask(_ task: Task) -> AnyPublisher<Task, APIError> {
        guard let body = try? jsonEncoder.encode(task) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/tasks", method: "POST", body: body)
    }
    
    func updateTask(_ task: Task) -> AnyPublisher<Task, APIError> {
        guard let body = try? jsonEncoder.encode(task) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/tasks/\(task.id)", method: "PUT", body: body)
    }
    
    func deleteTask(id: String) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/tasks/\(id)", method: "DELETE")
    }
    
    // MARK: - Communications API Methods
    
    func fetchCommunications() -> AnyPublisher<[Communication], APIError> {
        return request(from: "/api/communications", method: "GET")
    }
    
    func fetchCommunication(id: String) -> AnyPublisher<Communication, APIError> {
        return request(from: "/api/communications/\(id)", method: "GET")
    }
    
    func createCommunication(_ communication: Communication) -> AnyPublisher<Communication, APIError> {
        guard let body = try? jsonEncoder.encode(communication) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/communications", method: "POST", body: body)
    }
    
    func updateCommunication(_ communication: Communication) -> AnyPublisher<Communication, APIError> {
        guard let body = try? jsonEncoder.encode(communication) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/communications/\(communication.id)", method: "PUT", body: body)
    }
    
    func deleteCommunication(id: String) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/communications/\(id)", method: "DELETE")
    }
    
    // MARK: - Documents API Methods
    
    func fetchDocuments() -> AnyPublisher<[Document], APIError> {
        return request(from: "/api/documents", method: "GET")
    }
    
    func fetchDocument(id: String) -> AnyPublisher<Document, APIError> {
        return request(from: "/api/documents/\(id)", method: "GET")
    }
    
    func createDocument(_ document: Document) -> AnyPublisher<Document, APIError> {
        guard let body = try? jsonEncoder.encode(document) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return request(from: "/api/documents", method: "POST", body: body)
    }
    
    func deleteDocument(id: String) -> AnyPublisher<Void, APIError> {
        requestVoid(from: "/api/documents/\(id)", method: "DELETE")
    }
    
    // MARK: - Reports API Methods
    
    func fetchDashboardMetrics() -> AnyPublisher<ReportDashboardMetrics, APIError> {
        return request(from: "/api/reports/dashboard", method: "GET")
    }
    
    func fetchReport(type: ReportType, period: ReportPeriod, startDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<ReportData, APIError> {
        var components = URLComponents(string: "/api/reports/\(type.rawValue)")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "period", value: period.rawValue)
        ]
        
        if let startDate = startDate {
            let iso8601 = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "startDate", value: iso8601.string(from: startDate)))
        }
        
        if let endDate = endDate {
            let iso8601 = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "endDate", value: iso8601.string(from: endDate)))
        }
        
        components?.queryItems = queryItems
        
        guard let endpoint = components?.path, let query = components?.query else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return request(from: "\(endpoint)?\(query)", method: "GET")
    }
    
    // MARK: - Helper Methods
    
    private func requestVoid(from endpoint: String,
                             method: String,
                             body: Data? = nil) -> AnyPublisher<Void, APIError> {
        performRequest(from: endpoint, method: method, body: body)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    private func performRequest(from endpoint: String,
                                method: String,
                                body: Data?) -> AnyPublisher<Data, APIError> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Set JWT authentication header if available
        if let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.networkError("Invalid response.")
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    if httpResponse.statusCode == 401 {
                        throw APIError.unauthorized
                    }
                    throw APIError.serverError(httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
                return data
            }
            .mapError { error in
                if let apiError = error as? APIError { return apiError }
                return .networkError(error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func buildURL(for endpoint: String) -> URL? {
        let trimmed = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        // If endpoint starts with /, it's already a full path
        if trimmed.hasPrefix("/") {
            return URL(string: "\(baseURL.absoluteString)\(trimmed)")
        }
        
        // Otherwise, it's a relative path
        return baseURL.appendingPathComponent(trimmed)
    }
}

import Foundation

enum ClientType: String, Codable, CaseIterable {
    case seller
    case buyer
    case investor
    case partner
    case vendor
    case other
}

enum ClientStatus: String, Codable, CaseIterable {
    case active
    case inactive
    case prospect
    case archived
}

struct Client: Identifiable, Codable {
    var id: String
    var createdAt: Date
    var updatedAt: Date
    
    // Personal Information
    var firstName: String
    var lastName: String
    var company: String?
    var email: String
    var phone: String
    var secondaryPhone: String?
    
    // Client Details
    var type: ClientType
    var status: ClientStatus
    var source: String?
    var tags: [String]
    
    // Address
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    
    // Financial
    var totalValue: Double?
    var totalProjects: Int?
    var totalLeads: Int?
    
    // Notes and Communication
    var notes: String?
    var lastContactDate: Date?
    var nextFollowUpDate: Date?
    
    // Relationships
    var assignedTo: String?
    var leadId: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var displayName: String {
        if let company = company, !company.isEmpty {
            return "\(fullName) (\(company))"
        }
        return fullName
    }
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, company, email, phone, secondaryPhone
        case type, status, source, tags
        case address, city, state, zipCode
        case totalValue, totalProjects, totalLeads
        case notes, lastContactDate, nextFollowUpDate
        case assignedTo, leadId
        case createdAt, updatedAt
    }
}

import Foundation

enum DocumentType: String, Codable, CaseIterable {
    case contract
    case invoice
    case receipt
    case inspection
    case appraisal
    case photo
    case floorPlan = "floor_plan"
    case disclosure
    case agreement
    case other
    
    var displayName: String {
        switch self {
        case .contract: return "Contract"
        case .invoice: return "Invoice"
        case .receipt: return "Receipt"
        case .inspection: return "Inspection Report"
        case .appraisal: return "Appraisal"
        case .photo: return "Photo"
        case .floorPlan: return "Floor Plan"
        case .disclosure: return "Disclosure"
        case .agreement: return "Agreement"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .contract, .agreement: return "doc.text.fill"
        case .invoice, .receipt: return "dollarsign.circle.fill"
        case .inspection, .appraisal: return "checkmark.seal.fill"
        case .photo: return "photo.fill"
        case .floorPlan: return "building.2.fill"
        case .disclosure: return "exclamationmark.triangle.fill"
        case .other: return "doc.fill"
        }
    }
}

struct Document: Identifiable, Codable {
    var id: String
    var createdAt: Date
    var updatedAt: Date
    
    // Document Details
    var name: String
    var type: DocumentType
    var fileUrl: String
    var fileSize: Int64? // in bytes
    var mimeType: String?
    var description: String?
    
    // Relationships
    var uploadedBy: String
    var leadId: String?
    var clientId: String?
    var projectId: String?
    var propertyId: String?
    
    // Metadata
    var tags: [String]
    var isConfidential: Bool
    var expiryDate: Date?
    
    var fileSizeDisplay: String? {
        guard let fileSize = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, fileUrl, fileSize, mimeType, description
        case uploadedBy, leadId, clientId, projectId, propertyId
        case tags, isConfidential, expiryDate
        case createdAt, updatedAt
    }
}

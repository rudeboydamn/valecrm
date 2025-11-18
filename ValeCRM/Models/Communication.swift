import Foundation

enum CommunicationType: String, Codable, CaseIterable {
    case call
    case email
    case sms
    case meeting
    case note
    case voicemail
    case other
    
    var displayName: String {
        switch self {
        case .call: return "Call"
        case .email: return "Email"
        case .sms: return "SMS"
        case .meeting: return "Meeting"
        case .note: return "Note"
        case .voicemail: return "Voicemail"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .call: return "phone.fill"
        case .email: return "envelope.fill"
        case .sms: return "message.fill"
        case .meeting: return "person.2.fill"
        case .note: return "note.text"
        case .voicemail: return "voicemail"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum CommunicationDirection: String, Codable {
    case inbound
    case outbound
}

struct Communication: Identifiable, Codable {
    var id: String
    var createdAt: Date
    var updatedAt: Date
    
    // Communication Details
    var type: CommunicationType
    var direction: CommunicationDirection
    var subject: String?
    var content: String
    var duration: Int? // in seconds for calls
    
    // Relationships
    var userId: String // User who logged this communication
    var leadId: String?
    var clientId: String?
    var projectId: String?
    var propertyId: String?
    
    // Metadata
    var fromAddress: String? // email or phone
    var toAddress: String? // email or phone
    var attachments: [String]? // file URLs
    var tags: [String]
    
    var durationDisplay: String? {
        guard let duration = duration else { return nil }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var displayTitle: String {
        if let subject = subject, !subject.isEmpty {
            return subject
        }
        return "\(type.displayName) - \(direction == .inbound ? "Received" : "Sent")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, type, direction, subject, content, duration
        case userId, leadId, clientId, projectId, propertyId
        case fromAddress, toAddress, attachments, tags
        case createdAt, updatedAt
    }
}

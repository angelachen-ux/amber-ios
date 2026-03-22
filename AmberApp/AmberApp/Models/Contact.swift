// DATA-01: Contact graph — local SwiftData model

import Foundation
import SwiftData

@Model
final class Contact {
    var externalId: String          // CNContact.identifier
    var name: String
    var phoneNumbers: [String]
    var emails: [String]
    var birthday: Date?
    var messageFrequency: Int       // messages per 30 days
    var lastContactedAt: Date?
    var relationshipScore: Int      // 0–100
    var createdAt: Date
    var updatedAt: Date

    init(
        externalId: String,
        name: String,
        phoneNumbers: [String] = [],
        emails: [String] = [],
        birthday: Date? = nil,
        messageFrequency: Int = 0,
        lastContactedAt: Date? = nil,
        relationshipScore: Int = 0
    ) {
        self.externalId = externalId
        self.name = name
        self.phoneNumbers = phoneNumbers
        self.emails = emails
        self.birthday = birthday
        self.messageFrequency = messageFrequency
        self.lastContactedAt = lastContactedAt
        self.relationshipScore = relationshipScore
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Human-readable relationship strength label
    var relationshipLabel: String {
        switch relationshipScore {
        case 75...100: return "Close friend"
        case 50..<75:  return "Friend"
        case 25..<50:  return "Acquaintance"
        default:       return "Distant contact"
        }
    }
}

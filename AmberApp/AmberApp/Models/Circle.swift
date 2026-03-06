// SOCIAL-01: Circle data model

import Foundation
import SwiftData

@Model
final class Circle {
    var remoteId: Int?
    var name: String
    var visibility: String          // "private" | "members" | "public"
    var inviteToken: String?
    var memberCount: Int
    var isOwner: Bool
    var createdAt: Date

    init(name: String, visibility: String = "private", isOwner: Bool = true) {
        self.name = name
        self.visibility = visibility
        self.memberCount = 1
        self.isOwner = isOwner
        self.createdAt = Date()
    }

    var shareLink: URL? {
        guard let token = inviteToken else { return nil }
        return URL(string: "https://amber.app/join/\(token)")
    }
}

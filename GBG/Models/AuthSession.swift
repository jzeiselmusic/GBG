import Foundation

struct AuthSession: Codable, Sendable, Equatable {
    let userId: String
    let displayName: String
}


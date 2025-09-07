import Foundation

protocol AuthService: Sendable {
    func signIn(email: String, password: String) async throws -> AuthSession
    func signOut() async
    func currentSession() async -> AuthSession?
}

actor DefaultAuthService: AuthService {
    private var session: AuthSession? = nil

    func signIn(email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: 250_000_000)
        // Very simple mock: accept any non-empty credentials
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing credentials"])
        }
        let name = email.split(separator: "@").first.map(String.init) ?? "User"
        let newSession = AuthSession(userId: "user_1", displayName: name.capitalized)
        session = newSession
        return newSession
    }

    func signOut() async {
        session = nil
        // Simulate small delay for consistency
        try? await Task.sleep(nanoseconds: 120_000_000)
    }

    func currentSession() async -> AuthSession? {
        session
    }
}


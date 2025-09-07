import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userId: String? = nil

    func signIn(email: String, password: String) async throws {
        // Simulate network latency and successful sign-in
        try await Task.sleep(nanoseconds: 300_000_000)
        self.userId = "user_1"
        self.isSignedIn = true
    }

    func signOut() {
        self.isSignedIn = false
        self.userId = nil
    }
}


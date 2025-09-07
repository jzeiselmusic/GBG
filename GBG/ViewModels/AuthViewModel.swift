import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userId: String? = nil

    private let service: any AuthService

    init(service: any AuthService = DefaultAuthService()) {
        self.service = service
        Task { await refreshFromService() }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await service.signIn(email: email, password: password)
        self.userId = session.userId
        self.isSignedIn = true
    }

    func signOut() async {
        await service.signOut()
        self.isSignedIn = false
        self.userId = nil
    }

    private func refreshFromService() async {
        if let session = await service.currentSession() {
            self.userId = session.userId
            self.isSignedIn = true
        } else {
            self.userId = nil
            self.isSignedIn = false
        }
    }
}

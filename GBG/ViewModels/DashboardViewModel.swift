import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var summary: UserSummary?
    @Published var ledger: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: any GlitterboxAPI
    private let userId: String

    init(api: GlitterboxAPI, userId: String) {
        self.api = api
        self.userId = userId
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let api = self.api // capture locally to avoid MainActor property crossing
            let userId = self.userId
            async let summary = api.fetchUserSummary(userId: userId)
            async let ledger = api.fetchUserLedger(userId: userId)
            self.summary = try await summary
            self.ledger = try await ledger
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

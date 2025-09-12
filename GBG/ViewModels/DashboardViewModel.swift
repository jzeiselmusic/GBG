import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var summary: UserSummary?
    @Published var companySummary: CompanySummary?
    @Published var ledger: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private(set) var hasLoaded = false

    private let api: any GlitterboxAPI
    private(set) var userId: String

    init(api: GlitterboxAPI, userId: String) {
        self.api = api
        self.userId = userId
    }

    func load() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let api = self.api
            let uid = self.userId
            async let summary = api.fetchUserSummary(userId: uid)
            async let totalSummary = api.fetchCompanySummary()
            async let ledger = api.fetchUserLedger(userId: uid)
            self.summary = try await summary
            self.companySummary = try await totalSummary
            self.ledger = try await ledger
            self.hasLoaded = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func loadIfNeeded() async {
        if hasLoaded { return }
        await load()
    }

    func updateUser(id: String) {
        guard id != self.userId else { return }
        self.userId = id
        self.summary = nil
        self.ledger = []
        self.hasLoaded = false
        self.errorMessage = nil
    }
}

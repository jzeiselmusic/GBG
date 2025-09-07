import Foundation
import Combine

@MainActor
final class LedgerViewModel: ObservableObject {
    @Published var companySummary: CompanySummary?
    @Published var universalLedger: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: any GlitterboxAPI

    init(api: GlitterboxAPI) {
        self.api = api
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let api = self.api // capture outside of async lets to avoid crossing MainActor boundary
            async let summary = api.fetchCompanySummary()
            async let ledger = api.fetchUniversalLedger()
            self.companySummary = try await summary
            self.universalLedger = try await ledger
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

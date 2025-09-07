import Foundation

protocol GlitterboxAPI: Sendable {
    func fetchCompanySummary() async throws -> CompanySummary
    func fetchUniversalLedger() async throws -> [Transaction]
    func fetchUserSummary(userId: String) async throws -> UserSummary
    func fetchUserLedger(userId: String) async throws -> [Transaction]
}

actor MockGlitterboxAPI: GlitterboxAPI {
    private let users = [
        (id: "user_1", name: "001"),
        (id: "user_2", name: "002"),
        (id: "user_3", name: "003")
    ]

    func fetchCompanySummary() async throws -> CompanySummary {
        try await Task.sleep(nanoseconds: 150_000_000)
        return CompanySummary(totalReservesGrams: 125_000.75)
    }

    func fetchUniversalLedger() async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 150_000_000)
        let now = Date()
        var items: [Transaction] = []
        for i in 0..<40 {
            let type: TransactionType = (i % 3 == 0) ? .buy : (i % 3 == 1 ? .sell : .transfer)
            let delta = TimeInterval(60 * 20 * (i + 1))
            let amount = Double((i % 9 + 1) * 3)
            let from = type == .buy ? nil : users[i % users.count].name
            let to = type == .sell ? nil : users[(i + 1) % users.count].name
            items.append(Transaction(date: now.addingTimeInterval(-delta), type: type, fromUser: from, toUser: to, amountGrams: amount, note: nil))
        }
        return items.sorted { $0.date > $1.date }
    }

    func fetchUserSummary(userId: String) async throws -> UserSummary {
        try await Task.sleep(nanoseconds: 120_000_000)
        let name = users.first(where: { $0.id == userId })?.name ?? "User"
        let reserves = userId.hashValue.magnitude % 10_000
        return UserSummary(userId: userId, displayName: name, reservesGrams: Double(reserves))
    }

    func fetchUserLedger(userId: String) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 120_000_000)
        let name = users.first(where: { $0.id == userId })?.name ?? "User"
        let now = Date()
        var items: [Transaction] = []
        for i in 0..<30 {
            let type: TransactionType = (i % 2 == 0) ? .buy : .transfer
            let delta = TimeInterval(60 * 30 * (i + 1))
            let amount = Double((i % 7 + 1) * 2)
            let from = type == .buy ? nil : name
            let to = type == .buy ? name : users[(i + 1) % users.count].name
            items.append(Transaction(date: now.addingTimeInterval(-delta), type: type, fromUser: from, toUser: to, amountGrams: amount, note: nil))
        }
        return items.sorted { $0.date > $1.date }
    }
}

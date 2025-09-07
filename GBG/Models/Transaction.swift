import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case buy
    case sell
    case transfer
}

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let type: TransactionType
    let fromUser: String?
    let toUser: String?
    let amountGrams: Double
    let note: String?

    init(id: UUID = UUID(), date: Date, type: TransactionType, fromUser: String? = nil, toUser: String? = nil, amountGrams: Double, note: String? = nil) {
        self.id = id
        self.date = date
        self.type = type
        self.fromUser = fromUser
        self.toUser = toUser
        self.amountGrams = amountGrams
        self.note = note
    }
}

struct CompanySummary: Codable, Hashable {
    let totalReservesGrams: Double
}

struct UserSummary: Codable, Hashable {
    let userId: String
    let displayName: String
    let reservesGrams: Double
}

extension Double {
    var formattedGrams: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return (nf.string(from: NSNumber(value: self)) ?? "\(self)") + " g"
    }
}


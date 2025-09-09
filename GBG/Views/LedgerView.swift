import SwiftUI

struct LedgerView: View {
    @ObservedObject var viewModel: LedgerViewModel
    
    var body: some View {
        LazyVStack(spacing: 16) {
            if viewModel.isLoading && viewModel.universalLedger.isEmpty {
                ProgressView()
                    .tint(Color("PrimaryGold"))
                    .padding()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                if let summary = viewModel.companySummary {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Total Company Reserves")
                                .font(.headline)
                                .foregroundColor(Color("NormalWhite"))
                            Spacer()
                        }
                        HStack {
                            Text(summary.totalReservesGrams.formattedGrams)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("PrimaryGold"))
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Universal Ledger")
                            .font(.headline)
                            .foregroundColor(Color("NormalWhite"))
                        Spacer()
                    }
                    
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.universalLedger) { tx in
                            TransactionRow(transaction: tx)
                        }
                    }
                }
            }
        }
        .task { await viewModel.loadIfNeeded() }
        .refreshable { await viewModel.load() }
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .imageScale(Image.Scale.large)
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText)
                    .font(.custom("Courier", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color("NormalWhite"))
                Text(secondaryText)
                    .font(.custom("Courier", size: 12))
                    .foregroundStyle(.secondary)
                    .foregroundColor(Color("NormalWhite"))
            }
            Spacer()

            Text(transaction.amountGrams.formattedGrams)
                .font(.subheadline)
                .foregroundStyle(Color("PrimaryGold"))
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch transaction.type {
        case .buy: return "arrow.down.circle.fill"
        case .sell: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .buy: return Color("NormalWhite")
        case .sell: return Color("NormalWhite")
        case .transfer: return Color("NormalWhite")
        }
    }

    private var primaryText: String {
        switch transaction.type {
        case .buy:
            return "001 → \(transaction.toUser ?? "")"
        case .sell:
            return "001 ← \(transaction.fromUser ?? "")"
        case .transfer:
            return "\(transaction.fromUser ?? "?") → \(transaction.toUser ?? "?")"
        }
    }

    private var secondaryText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        let date = df.string(from: transaction.date)
        if let note = transaction.note, !note.isEmpty {
            return "\(date) · \(note)"
        }
        return date
    }
}

#Preview {
    LedgerView(viewModel: LedgerViewModel(api: MockGlitterboxAPI()))
}

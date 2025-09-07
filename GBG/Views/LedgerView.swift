import SwiftUI

struct LedgerView: View {
    @StateObject private var viewModel: LedgerViewModel

    init(api: GlitterboxAPI) {
        _viewModel = StateObject(wrappedValue: LedgerViewModel(api: api))
    }

    var body: some View {
        Group {
                if viewModel.isLoading && viewModel.universalLedger.isEmpty {
                    ProgressView()
                        .tint(Color("PrimaryGold"))
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
                    List {
                        if let summary = viewModel.companySummary {
                            Section("Total Company Reserves") {
                                HStack {
                                    Text(summary.totalReservesGrams.formattedGrams)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color("PrimaryGold"))
                                    Spacer()
                                }
                                .listRowBackground(Color(.systemGray6))
                            }
                        }

                        Section("Universal Ledger") {
                            ForEach(viewModel.universalLedger) { tx in
                                TransactionRow(transaction: tx)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .background(Color("AppBackground"))
                    .refreshable { await viewModel.load() }
                }
        }
        .task { await viewModel.load() }
        .background(Color("AppBackground").ignoresSafeArea())
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
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(secondaryText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
        case .buy: return .gray
        case .sell: return .gray
        case .transfer: return .gray
        }
    }

    private var primaryText: String {
        switch transaction.type {
        case .buy:
            return "Buy → \(transaction.toUser ?? "")"
        case .sell:
            return "Sell ← \(transaction.fromUser ?? "")"
        case .transfer:
            return "Transfer: \(transaction.fromUser ?? "?") → \(transaction.toUser ?? "?")"
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
    LedgerView(api: MockGlitterboxAPI())
}

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
                            HStack {
                                Text("Total Company Reserves")
                                    .font(.headline)
                                    .foregroundColor(Color("NormalWhite"))
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            
                            HStack {
                                Text(summary.totalReservesGrams.formattedGrams)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("PrimaryGold"))
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color(Color("AppBackground")))
                            .listRowSeparator(.hidden)
                        }
                        
                        HStack {
                            Text("Universal Ledger")
                                .font(.headline)
                                .foregroundColor(Color("NormalWhite"))
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        ForEach(viewModel.universalLedger) { tx in
                            TransactionRow(transaction: tx)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .listSectionSpacing(.compact)
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    .scrollContentBackground(.hidden)
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
    LedgerView(api: MockGlitterboxAPI())
}

import SwiftUI
import RHLinePlot

struct LedgerView: View {
    @ObservedObject var viewModel: LedgerViewModel
    @State var spotPrice: CGFloat? = nil
    
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Spot Price")
                                .font(.headline)
                                .foregroundColor(Color("NormalWhite"))
                            Spacer()
                        }
                        HStack {
                            Text(summary.spotPriceDollarsPerGram.formattedDollarPerGram)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("PrimaryGold"))
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                GBPlot(
                    demoValues: [3650.5, 3651.2, 3651.5, 3652.3, 3652.6, 3651.7, 3659.3, 3660.4, 3660.3, 3660.6],
                    demoSegments: [0, 4, 7],
                )
                
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

#Preview {
    LedgerView(viewModel: LedgerViewModel(api: MockGlitterboxAPI()))
}

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        LazyVStack(spacing: 16) {
            if viewModel.isLoading && viewModel.ledger.isEmpty {
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
                if let summary = viewModel.summary {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Your Gold Balance")
                                .font(.headline)
                                .foregroundColor(Color("NormalWhite"))
                            Spacer()
                        }
                        HStack {
                            Text(summary.reservesGrams.formattedGrams)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("PrimaryGold"))
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if let companySummary = viewModel.companySummary {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Current Market Value")
                                    .font(.headline)
                                    .foregroundColor(Color("NormalWhite"))
                                Spacer()
                            }
                            HStack {
                                Text("\((companySummary.spotPriceDollarsPerGram * summary.reservesGrams).formattedDollar)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("PrimaryGold"))
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                GBPlot(
                    demoValues: [5.0, 5.24, 4.5, 6.23, 7.8, 8.5, 3.43, 10.0],
                    demoSegments: [0, 2, 4, 6]
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("My Ledger")
                            .font(.headline)
                            .foregroundColor(Color("NormalWhite"))
                        Spacer()
                    }
                    
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.ledger) { tx in
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

// (Transfer content lives in TransferView.swift)

#Preview {
    DashboardView(viewModel: DashboardViewModel(api: MockGlitterboxAPI(), userId: "user_1"))
        .environmentObject(AuthViewModel())
}

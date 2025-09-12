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
                    // Top card with User ID and Membership Tier, visually separated
                    VStack(spacing: 12) {
                        VStack(alignment: .center, spacing: 6) {
                            Text("User ID")
                                .font(.headline)
                                .foregroundColor(Color("NormalWhite"))
                            Text("#\(summary.displayName)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("PrimaryGold"))
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .background(Color.white.opacity(0.15))

                        HStack(spacing: 8) {
                            VStack(alignment: .center, spacing: 6) {
                                Text("Membership Tier")
                                    .font(.headline)
                                    .foregroundColor(Color("NormalWhite"))
                                HStack(spacing: 4) {
                                    Text("Founding Member")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color("PrimaryGold"))
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color("PrimaryGold"))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.25), lineWidth: 1)
                            )
                    )
                    .padding(.vertical, 8)

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

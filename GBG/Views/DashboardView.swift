import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if viewModel.isLoading && viewModel.ledger.isEmpty {
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
                        if let summary = viewModel.summary {
                            // Header-like row
                            HStack {
                                Text("My Reserves")
                                    .font(.headline)
                                    .foregroundColor(Color("NormalWhite"))
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                            // Value row
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(summary.reservesGrams.formattedGrams)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color("PrimaryGold"))
                                }
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }

                        // Second header-like row
                        HStack {
                            Text("My Ledger")
                                .font(.headline)
                                .foregroundColor(Color("NormalWhite"))
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                        ForEach(viewModel.ledger) { tx in
                            TransactionRow(transaction: tx)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
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
        }
        .task { await viewModel.loadIfNeeded() }
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

// (Transfer content lives in TransferView.swift)

#Preview {
    DashboardView(viewModel: DashboardViewModel(api: MockGlitterboxAPI(), userId: "user_1"))
        .environmentObject(AuthViewModel())
}

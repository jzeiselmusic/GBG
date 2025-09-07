import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showTransferSheet = false

    var body: some View {
        ZStack {
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

            VStack { // Floating action buttons
                Spacer()
                HStack(spacing: 20) {
                    FloatingActionButton(systemImage: "cart.fill", label: "Buy") { showTransferSheet = true }
                    FloatingActionButton(systemImage: "arrow.up", label: "Sell") { showTransferSheet = true }
                    FloatingActionButton(systemImage: "arrow.left.arrow.right", label: "Transfer") { showTransferSheet = true }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .fullScreenCover(isPresented: $showTransferSheet) {
                TransferView()
            }
        }
        .task { await viewModel.loadIfNeeded() }
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

private struct FloatingActionButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color("SecondaryGold")).opacity(0.7))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(Text(label))
        .buttonStyle(.plain)
    }
}

// (Transfer content lives in TransferView.swift)

#Preview {
    DashboardView(viewModel: DashboardViewModel(api: MockGlitterboxAPI(), userId: "user_1"))
        .environmentObject(AuthViewModel())
}

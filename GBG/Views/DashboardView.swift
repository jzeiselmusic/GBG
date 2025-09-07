import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(api: GlitterboxAPI, userId: String) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(api: api, userId: userId))
    }

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
                            Section("My Reserves") {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(summary.displayName)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text(summary.reservesGrams.formattedGrams)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color("PrimaryGold"))
                                    }
                                    Spacer()
                                }
                                .listRowBackground(Color(.systemGray6))
                            }
                        }
                        Section("My Ledger") {
                            ForEach(viewModel.ledger) { tx in
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

            VStack { // Floating action buttons
                Spacer()
                HStack(spacing: 20) {
                    FloatingActionButton(systemImage: "cart.fill", label: "Buy") {
                        // TODO: Hook up buy flow
                    }
                    FloatingActionButton(systemImage: "arrow.up", label: "Sell") {
                        // TODO: Hook up sell flow
                    }
                    FloatingActionButton(systemImage: "arrow.left.arrow.right", label: "Transfer") {
                        // TODO: Hook up transfer flow
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .task { await viewModel.load() }
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
                .background(Circle().fill(Color("PrimaryGold")))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(Text(label))
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView(api: MockGlitterboxAPI(), userId: "user_1")
}

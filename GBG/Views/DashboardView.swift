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
                TransferSheet()
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

private struct TransferSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var isSubmitting = false

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("PrimaryGold"))
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray6)))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }

                Text("Transfer Gold").font(.title2).bold()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount (grams)").font(.subheadline).foregroundStyle(.secondary)
                    TextField("e.g. 25.0", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                Spacer()

                Button {
                    Task { await submit() }
                } label: {
                    if isSubmitting {
                        ProgressView().tint(Color("AppBackground")).frame(maxWidth: .infinity)
                    } else {
                        Text("Continue").fontWeight(.semibold).frame(maxWidth: .infinity)
                    }
                }
                .disabled(!isValid)
                .frame(height: 48)
                .background(isValid ? Color("PrimaryGold") : Color(.systemGray3))
                .foregroundStyle(Color("AppBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
        }
    }

    private var isValid: Bool { (Double(amount) ?? 0) > 0 }

    private func submit() async {
        guard isValid else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 400_000_000)
        dismiss()
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel(api: MockGlitterboxAPI(), userId: "user_1"))
        .environmentObject(AuthViewModel())
}

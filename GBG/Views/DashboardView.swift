import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var activeSheet: TransactionSheet?
    @State private var showAllIcons: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    enum TransactionSheet: Identifiable {
        case buy, sell, transfer
        var id: Self { self }
    }

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
            
            if showAllIcons {
                Color.black.opacity(0.0001) // invisible but hittable
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { showAllIcons = false } }
                    .transition(.opacity)
            }

            VStack(spacing: 12) {
                if showAllIcons {
                    let items: [(Image, String, () -> Void)] = [
                        (Image(systemName: "cart.fill"), "Buy", { activeSheet = .buy; showAllIcons = false }),
                        (Image(systemName: "arrow.up"), "Sell", { activeSheet = .sell; showAllIcons = false }),
                        (Image(systemName: "arrow.left.arrow.right"), "Transfer", { activeSheet = .transfer; showAllIcons = false })
                    ]

                    ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                        FloatingActionButton(icon: item.0, label: item.1, action: item.2)
                            .transition(.move(edge: .bottom).combined(with: .opacity)) // <- vertical entrance
                            .animation(.spring(response: 0.28, dampingFraction: 0.85).delay(Double(i) * 0.25),
                                       value: showAllIcons) // slight stagger
                    }
                }

                // The main FAB that toggles the expansion
                CollectiveActionButton(
                    icon: Image("GoldIcon"),
                    label: "all"
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        showAllIcons.toggle()
                    }
                }
            }
            .fullScreenCover(item: $activeSheet) { sheet in
                switch sheet {
                case .buy:      BuyView()
                case .sell:     SellView()
                case .transfer: TransferView()
                }
            }
            .padding(.bottom, 24)
        }
        .task { await viewModel.loadIfNeeded() }
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

private struct CollectiveActionButton: View {
    let icon: Image
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .font(.system(size: 22, weight: .bold))
                .frame(width: 85, height: 85)
                .background(Circle().fill(Color.clear))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(Text(label))
        .buttonStyle(.plain)
    }
}

private struct FloatingActionButton: View {
    let icon: Image
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
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

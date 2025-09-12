import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @State private var navigationSelected: Tab = .ledger
    private let iconHeight: CGFloat = 65
    private let iconWidth: CGFloat = 135
    @StateObject private var ledgerVM: LedgerViewModel
    @StateObject private var dashboardVM: DashboardViewModel
    @State private var activeSheet: TransactionSheet?
    @State private var buttonFlipped: Bool = false
    @State private var showAllIcons: Bool = false
    @State private var sparkleToken = 0

    enum Tab { case ledger, user }
    
    enum TransactionSheet: Identifiable {
        case buy, sell, transfer
        var id: Self { self }
    }

    init() {
        let api = MockGlitterboxAPI()
        _ledgerVM = StateObject(wrappedValue: LedgerViewModel(api: api))
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(api: api, userId: ""))
    }
    
    private func toggleButton() {
        if (showAllIcons) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                showAllIcons = false
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                buttonFlipped = false
            }
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                showAllIcons = true
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                buttonFlipped = true
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(spacing: 32) {
                        IconTabButton(
                            systemImage: "chart.bar.xaxis", 
                            isSelected: navigationSelected == .ledger, 
                            height: iconHeight,
                            width: iconWidth
                        ) {
                            navigationSelected = .ledger
                        }
                        IconTabButton(
                            systemImage: "person.circle", 
                            isSelected: navigationSelected == .user, 
                            height: iconHeight,
                            width: iconWidth
                        ) {
                            navigationSelected = .user
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    .background(Color("AppBackground"))
                    .animation(.easeInOut(duration: 0.3), value: true)
                    
                    // Scrollable content
                    ScrollView {
                        // Dynamic content based on selected tab
                        Group {
                            switch navigationSelected {
                                case .ledger:
                                    LedgerView(viewModel: ledgerVM)
                                case .user:
                                    if let userId = auth.userId, auth.isSignedIn {
                                        DashboardView(viewModel: dashboardVM)
                                    } else {
                                        SignInView().environmentObject(auth)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .refreshable { }
                }
                
                if (auth.isSignedIn) {
                    if showAllIcons {
                        Color.black.opacity(0.0001) // invisible but hittable
                            .ignoresSafeArea()
                            .onTapGesture { toggleButton() }
                            .transition(.opacity)
                    }
                    
                    VStack(spacing: 12) {
                        if showAllIcons {
                            let items: [(Image, String, () -> Void)] = [
                                (Image(systemName: "cart.fill"), "Buy", {
                                    activeSheet = .buy
                                    toggleButton()
                                }),
                                (Image(systemName: "arrow.up"), "Sell", {
                                    activeSheet = .sell
                                    toggleButton()
                                }),
                                (Image(systemName: "arrow.left.arrow.right"), "Transfer", {
                                    activeSheet = .transfer
                                    toggleButton()
                                })
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
                            label: "all",
                            flipped: buttonFlipped
                        ) { toggleButton() }
                    }
                    .fullScreenCover(item: $activeSheet) { sheet in
                        switch sheet {
                        case .buy:      TransactionView(transactionType: .buy, onCompletedTransaction: { sparkleToken += 1 })
                        case .sell:     TransactionView(transactionType: .sell, onCompletedTransaction: { sparkleToken += 1 })
                        case .transfer: TransactionView(transactionType: .transfer, onCompletedTransaction: { sparkleToken += 1 })
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .overlay(TwinkleOverlay(fireToken: $sparkleToken))
        .environmentObject(auth)
        .tint(Color("PrimaryGold"))
        .onChange(of: auth.userId) { _, newValue in
            if let id = newValue {
                dashboardVM.updateUser(id: id)
            } else {
                dashboardVM.updateUser(id: "")
            }
        }
    }
}

#Preview {
    ContentView()
}

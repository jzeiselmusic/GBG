import SwiftUI
import Twinkle

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @State private var navigationSelected: Tab = .ledger
    private let iconHeight: CGFloat = 65
    private let iconWidth: CGFloat = 135
    @StateObject private var ledgerVM: LedgerViewModel
    @StateObject private var dashboardVM: DashboardViewModel
    @State private var activeSheet: TransactionSheet?
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

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 12) {
                    // Top tab bar with icons only
                    HStack(spacing: 32) {
                        IconTabButton(systemImage: "chart.bar.xaxis", isSelected: navigationSelected == .ledger, height: iconHeight, width: iconWidth) {
                            navigationSelected = .ledger
                        }
                        IconTabButton(systemImage: "person.circle", isSelected: navigationSelected == .user, height: iconHeight, width: iconWidth) {
                            navigationSelected = .user
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Main content
                    Group {
                        switch navigationSelected {
                            case .ledger:
                                LedgerView(viewModel: ledgerVM)
                            case .user:
                                if let userId = auth.userId, auth.isSignedIn {
                                    DashboardView(viewModel: dashboardVM)
                                } else {
                                    SignInView()
                                        .environmentObject(auth)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if (auth.isSignedIn) {
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
                        case .buy:      TransactionView(transactionType: .buy, onCompletedTransaction: { sparkleToken += 1 })
                        case .sell:     TransactionView(transactionType: .sell, onCompletedTransaction: { })
                        case .transfer: TransactionView(transactionType: .transfer, onCompletedTransaction: { })
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

private struct IconTabButton: View {
    let systemImage: String
    var isSelected: Bool = false
    var height: CGFloat
    var width: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable() // make SF Symbol scalable
                .scaledToFit()
                .frame(
                    width: width * 0.5,   // icon scales to 50% of button size
                    height: height * 0.5
                )
                .foregroundStyle(isSelected ? Color("NormalWhite") : Color("SecondaryGold"))
                .frame(width: width, height: height) // button hit area
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color("SecondaryGold") : Color.clear)
                        .opacity(0.7)
                )
                .overlay( // border
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color.black, lineWidth: 0.5)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0) // shrink when pressed
                .animation(.spring(response: 0.15, dampingFraction: 0.7), value: isPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
        }
        .buttonStyle(.plain)
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

struct TwinkleOverlay: UIViewRepresentable {
    @Binding var fireToken: Int   // increment this to fire

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        v.clipsToBounds = false
        return v
    }

    func updateUIView(_ v: UIView, context: Context) {
        // Only fire when token changes AND we have a valid size
        if context.coordinator.lastToken != fireToken, v.bounds.size != .zero {
            context.coordinator.lastToken = fireToken
            var config = Twinkle.Configuration()
            config.minCount = 15
            config.maxCount = 25
            config.birthRate = 36
            config.scale = 1.0
            config.lifetime = 0.5
            config.spin = 2.0
            Twinkle.twinkle(v, configuration: config)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var lastToken: Int = 0 }
}

#Preview {
    ContentView()
}

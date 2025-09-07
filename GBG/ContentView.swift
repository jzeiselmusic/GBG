import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @State private var navigationSelected: Tab = .ledger
    private let iconHeight: CGFloat = 65
    private let iconWidth: CGFloat = 135
    @StateObject private var ledgerVM: LedgerViewModel
    @StateObject private var dashboardVM: DashboardViewModel

    enum Tab { case ledger, user }

    init() {
        let api = MockGlitterboxAPI()
        _ledgerVM = StateObject(wrappedValue: LedgerViewModel(api: api))
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(api: api, userId: ""))
    }

    var body: some View {
        NavigationStack {
            ZStack {
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
            }
            .toolbar(.hidden, for: .navigationBar)
        }
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

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable() // make SF Symbol scalable
                .scaledToFit()
                .frame(
                    width: width * 0.5,   // icon scales to 50% of button size
                    height: height * 0.5
                )
                .foregroundStyle(isSelected ? Color("NormalWhite") : Color("PrimaryGold"))
                .frame(width: width, height: height) // button hit area
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color("PrimaryGold") : Color("NormalWhite"))
                        .opacity(0.6)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}

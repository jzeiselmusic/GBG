import SwiftUI

struct UserContainerView: View {
    @EnvironmentObject var auth: AuthViewModel
    private let api = MockGlitterboxAPI()

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            if let userId = auth.userId, auth.isSignedIn {
                DashboardView(api: api, userId: userId)
                    .navigationTitle("Dashboard")
            } else {
                SignInView()
                    .navigationTitle("Sign In")
            }
        }
    }
}

#Preview {
    UserContainerView().environmentObject(AuthViewModel())
}


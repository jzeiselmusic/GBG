import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isWorking: Bool = false
    @State private var error: String?

    var body: some View {
        Form {
            Section("Account") {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task { await signIn() }
                    } label: {
                        if isWorking {
                            ProgressView()
                                .tint(Color("PrimaryGold"))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isWorking || email.isEmpty || password.isEmpty)
                }
            }
            .tint(Color("PrimaryGold"))
            .scrollContentBackground(.hidden)
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .background(Color("AppBackground"))
        }

    private func signIn() async {
        error = nil
        isWorking = true
        defer { isWorking = false }
        do {
            try await auth.signIn(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    SignInView().environmentObject(AuthViewModel())
}

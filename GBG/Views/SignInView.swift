import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isWorking: Bool = false
    @State private var error: String?

    var body: some View {
        Form {
            Section(header: Text("Sign In")
                .foregroundColor(Color("NormalWhite"))
                .font(.headline)) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.black)
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .foregroundColor(.black)
            }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    if isWorking {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(Color("PrimaryGold"))
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        Button {
                            Task { await signIn() }
                        } label: {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(isWorking || email.isEmpty || password.isEmpty)
                    }
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

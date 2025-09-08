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
                .font(.headline)
                .padding(5.0)
            ) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.black)
                    .padding(5.0)
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .foregroundColor(.black)
                    .padding(5.0)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

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
                        if isWorking {
                            ProgressView().tint(Color("AppBackground"))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign in")
                                .fontWeight(.semibold)
                                .foregroundColor(Color("AppBackground"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isValid())
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(isValid() ? Color("SecondaryGold") : Color(.systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .tint(Color("PrimaryGold"))
        .scrollContentBackground(.hidden)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .background(Color("AppBackground"))
    }
    
    private func isValid() -> Bool {
        return !(isWorking || email.isEmpty || password.isEmpty)
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

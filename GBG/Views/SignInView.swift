import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isWorking: Bool = false
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sign In")
                    .foregroundColor(Color("NormalWhite"))
                    .font(.headline)
                
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                if let error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                if isWorking {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color("PrimaryGold"))
                        Spacer()
                    }
                } else {
                    Button {
                        Task { await signIn() }
                    } label: {
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .foregroundColor(Color("AppBackground"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .disabled(!isValid())
                    .background(isValid() ? Color("SecondaryGold") : Color(.systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.vertical, 20)
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

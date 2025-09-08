import SwiftUI

struct TransferView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String = ""
    @State private var isSubmitting = false
    
    init() {
        print("showing transfer view")
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("SecondaryGold"))
                            .padding(10)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

                Text("Transfer Gold")
                    .font(.headline).bold()
                    .foregroundColor(Color("NormalWhite"))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount (grams)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("e.g. 26.0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    Task { await submit() }
                } label: {
                    if isSubmitting {
                        ProgressView().tint(Color("AppBackground"))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!isValid)
                .frame(height: 48)
                .background(isValid ? Color("SecondaryGold") : Color(.systemGray3))
                .foregroundStyle(Color("AppBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
        }
    }

    private var isValid: Bool {
        guard let v = Double(amountText), v > 0 else { return false }
        return true
    }

    private func submit() async {
        guard isValid else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 400_000_000)
        dismiss()
    }
}

#Preview {
    TransferView()
}


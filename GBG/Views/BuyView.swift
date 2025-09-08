import SwiftUI

struct BuyView: View {
    @Environment(\.dismiss) private var dismiss

    enum InputMode: String, CaseIterable, Identifiable { case grams = "Grams", usd = "USD"; var id: String { rawValue } }

    @State private var mode: InputMode = .grams
    @State private var amountText: String = ""
    @State private var isSubmitting = false

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

                Text("Buy Gold")
                    .font(.headline).bold()
                    .foregroundColor(Color("NormalWhite"))

                // Input Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Input Mode").font(.subheadline).foregroundStyle(.secondary)
                    Picker("Input Mode", selection: $mode) {
                        ForEach(InputMode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Amount
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount (\(mode == .grams ? "grams" : "USD"))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField(mode == .grams ? "e.g. 10.5" : "e.g. 500.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                Spacer()

                Button {
                    Task { await submit() }
                } label: {
                    if isSubmitting {
                        ProgressView().tint(Color("AppBackground"))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Place Buy Order")
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

    private var isValid: Bool { (Double(amountText) ?? 0) > 0 }

    private func submit() async {
        guard isValid else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 500_000_000)
        dismiss()
    }
}

#Preview { BuyView() }


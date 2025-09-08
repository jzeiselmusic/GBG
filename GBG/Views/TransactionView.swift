//
//  TransactionView.swift
//  GBG
//
//  Created by Jacob Zeisel on 9/8/25.
//

import SwiftUI

struct TransactionView: View {
    @Environment(\.dismiss) private var dismiss

    enum InputMode: String, CaseIterable, Identifiable { case grams = "Grams", usd = "USD"; var id: String { rawValue } }

    @State private var mode: InputMode = .grams
    @State private var amountText: String = ""
    @State private var fromText: String = ""
    @State private var toText: String = ""
    @State private var isSubmitting = false
    
    private let transactionType: TransactionType
    private let onCompletedTransaction: () -> Void
    
    
    init(
        transactionType: TransactionType,
        onCompletedTransaction: @escaping () -> Void
    ) {
        self.transactionType = transactionType
        self.onCompletedTransaction = onCompletedTransaction
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("SecondaryGold"))
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
                
                if (transactionType == .buy) {
                    Text("Buy Gold")
                        .font(.headline).bold()
                        .foregroundColor(Color("NormalWhite"))
                } else if (transactionType == .sell) {
                    Text("Sell Gold")
                        .font(.headline).bold()
                        .foregroundColor(Color("NormalWhite"))
                } else if (transactionType == .transfer) {
                    Text("Transfer Gold")
                        .font(.headline).bold()
                        .foregroundColor(Color("NormalWhite"))
                }

                // Input Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Input Mode").font(.subheadline).foregroundStyle(.secondary)
                    Picker("Input Mode", selection: $mode) {
                        ForEach(InputMode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(height: 50.0)
                }

                // Amount
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount (\(mode == .grams ? "grams" : "USD"))")
                        .font(.subheadline)
                        .foregroundStyle(Color("NormalWhite"))
                    TextField(mode == .grams ? "e.g. 10.5" : "e.g. 500.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                if (transactionType == .transfer) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("From: ")
                            .font(.subheadline)
                            .foregroundStyle(Color("NormalWhite"))
                        TextField("e.g. 001", text: $fromText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("To: ")
                            .font(.subheadline)
                            .foregroundStyle(Color("NormalWhite"))
                        TextField("e.g. 003", text: $toText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Spacer()

                if isSubmitting {
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
                        Task { await submit() }
                    } label: {
                        Text("Transfer")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!isValid())
                    .frame(height: 48)
                    .background(isValid() ? Color("SecondaryGold") : Color(.systemGray3))
                    .foregroundStyle(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
    }

    private func isValid() -> Bool {
        if (transactionType == .buy) {
            return !(amountText.isEmpty)
        } else if (transactionType == .sell) {
            return !(amountText.isEmpty)
        } else if (transactionType == .transfer) {
            return !(amountText.isEmpty || toText.isEmpty || fromText.isEmpty)
        } else {
            return false
        }
    }

    private func submit() async {
        guard isValid() else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 500_000_000)
        onCompletedTransaction()
        dismiss()
    }
}

#Preview { TransactionView(transactionType: TransactionType.transfer, onCompletedTransaction: {}) }

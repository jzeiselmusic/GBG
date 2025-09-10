//
//  Transactions.swift
//  GBG
//
//  Created by Jacob Zeisel on 9/10/25.
//
import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .imageScale(Image.Scale.large)
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText)
                    .font(.custom("Courier", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color("NormalWhite"))
                Text(secondaryText)
                    .font(.custom("Courier", size: 12))
                    .foregroundStyle(.secondary)
                    .foregroundColor(Color("NormalWhite"))
            }
            Spacer()

            Text(transaction.amountGrams.formattedGrams)
                .font(.subheadline)
                .foregroundStyle(Color("PrimaryGold"))
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch transaction.type {
        case .buy: return "arrow.down.circle.fill"
        case .sell: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .buy: return Color("NormalWhite")
        case .sell: return Color("NormalWhite")
        case .transfer: return Color("NormalWhite")
        }
    }

    private var primaryText: String {
        switch transaction.type {
        case .buy:
            return "001 → \(transaction.toUser ?? "")"
        case .sell:
            return "001 ← \(transaction.fromUser ?? "")"
        case .transfer:
            return "\(transaction.fromUser ?? "?") → \(transaction.toUser ?? "?")"
        }
    }

    private var secondaryText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        let date = df.string(from: transaction.date)
        if let note = transaction.note, !note.isEmpty {
            return "\(date) · \(note)"
        }
        return date
    }
}

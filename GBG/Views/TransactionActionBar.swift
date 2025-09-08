import SwiftUI

struct TransactionActionBar: View {
    let onBuy: () -> Void
    let onSell: () -> Void
    let onTransfer: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            CircleButton(systemImage: "cart.fill", action: onBuy)
            CircleButton(systemImage: "arrow.up", action: onSell)
            CircleButton(systemImage: "arrow.left.arrow.right", action: onTransfer)
        }
        .padding(.horizontal, 24)
    }
}

private struct CircleButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color("PrimaryGold")))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        VStack {
            Spacer()
            TransactionActionBar(onBuy: {}, onSell: {}, onTransfer: {})
                .padding(.bottom, 24)
        }
    }
}

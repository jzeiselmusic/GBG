import SwiftUI

struct TransactionActionBar: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            CircleButton(systemImage: "cart.fill", action: action)
            CircleButton(systemImage: "arrow.up", action: action)
            CircleButton(systemImage: "arrow.left.arrow.right", action: action)
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
            TransactionActionBar { }
                .padding(.bottom, 24)
        }
    }
}


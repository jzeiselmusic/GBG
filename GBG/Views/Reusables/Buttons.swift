//
//  Buttons.swift
//  GBG
//
//  Created by Jacob Zeisel on 9/9/25.
//
import SwiftUI

struct IconTabButton: View {
    let systemImage: String
    var isSelected: Bool = false
    var height: CGFloat
    var width: CGFloat
    var isCompact: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * (isCompact ? 0.6 : 0.5),
                    height: height * (isCompact ? 0.6 : 0.5)
                )
                .foregroundStyle(isSelected ? Color("NormalWhite") : Color("SecondaryGold"))
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: isCompact ? 8 : 12)
                        .fill(isSelected ? Color("SecondaryGold") : Color.clear)
                        .opacity(isCompact ? 0.5 : 0.7)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 8 : 12)
                        .stroke(
                            isSelected ? Color.clear : (isCompact ? Color.clear : Color.black), 
                            lineWidth: isCompact ? 0 : 0.5
                        )
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.15, dampingFraction: 0.7), value: isPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
        }
        .buttonStyle(.plain)
    }
}

struct CollectiveActionButton: View {
    let icon: Image
    let label: String
    let flipped: Bool
    let action: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color("NormalWhite"))
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 2)
                    )

                // Icon
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)     // icon size
                    .rotationEffect(.degrees(flipped ? 180 : 0))
            }
            .frame(width: 85, height: 85)              // circle size
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(Text(label))
        .buttonStyle(.plain)
    }
}

struct FloatingActionButton: View {
    let icon: Image
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color("NormalWhite")).opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(Text(label))
        .buttonStyle(.plain)
    }
}

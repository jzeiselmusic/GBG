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
    let action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable() // make SF Symbol scalable
                .scaledToFit()
                .frame(
                    width: width * 0.5,   // icon scales to 50% of button size
                    height: height * 0.5
                )
                .foregroundStyle(isSelected ? Color("NormalWhite") : Color("SecondaryGold"))
                .frame(width: width, height: height) // button hit area
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color("SecondaryGold") : Color.clear)
                        .opacity(0.7)
                )
                .overlay( // border
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color.black, lineWidth: 0.5)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0) // shrink when pressed
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .font(.system(size: 22, weight: .bold))
                .frame(width: 85, height: 85)
                .background(Circle().fill(Color.clear))
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
                .background(Circle().fill(Color("SecondaryGold")).opacity(0.7))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(Text(label))
        .buttonStyle(.plain)
    }
}

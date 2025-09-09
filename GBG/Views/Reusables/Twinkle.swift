//
//  Twinkle.swift
//  GBG
//
//  Created by Jacob Zeisel on 9/9/25.
//
import SwiftUI
import Twinkle

struct TwinkleOverlay: UIViewRepresentable {
    @Binding var fireToken: Int   // increment this to fire

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        v.clipsToBounds = false
        return v
    }

    func updateUIView(_ v: UIView, context: Context) {
        // Only fire when token changes AND we have a valid size
        if context.coordinator.lastToken != fireToken, v.bounds.size != .zero {
            context.coordinator.lastToken = fireToken
            var config = Twinkle.Configuration()
            config.minCount = 15
            config.maxCount = 25
            config.birthRate = 36
            config.scale = 1.0
            config.lifetime = 0.5
            config.spin = 2.0
            Twinkle.twinkle(v, configuration: config)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var lastToken: Int = 0 }
}

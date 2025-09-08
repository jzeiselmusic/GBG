//
//  ConfettiEngine.swift
//  GBG
//
//  Created by Jacob Zeisel on 9/8/25.
//

import SwiftUI

// MARK: - Engine
final class ConfettiEngine: ObservableObject {
    struct Particle: Identifiable {
        let id = UUID()
        var pos: CGPoint
        var vel: CGPoint
        var angle: CGFloat
        var spin: CGFloat
        var color: Color
        var size: CGFloat
        var birth: CFTimeInterval
        var life: CFTimeInterval
    }

    @Published private(set) var particles: [Particle] = []
    private var lastTime: CFTimeInterval = 0
    var gravity: CGFloat = 500 // pts/s^2

    func emit(from origin: CGPoint, count: Int, colors: [Color]) {
        let now = CACurrentMediaTime()
        for _ in 0..<count {
            let speed = CGFloat.random(in: 250...600)
            // mostly upward, with spread
            let center = -CGFloat.pi / 2        // straight up
            let spread = CGFloat.pi / 3         // 60° total cone
            let theta = CGFloat.random(in: (center - spread)...(center + spread))
            let vel = CGPoint(x: cos(theta) * speed, y: sin(theta) * speed)
            let size = CGFloat.random(in: 8...16)
            let spin = CGFloat.random(in: -6...6)
            let life = CFTimeInterval.random(in: 2.0...3.0)
            let color = colors.randomElement() ?? .accentColor

            particles.append(Particle(
                pos: origin, vel: vel, angle: 0, spin: spin,
                color: color, size: size, birth: now, life: life
            ))
        }
        if lastTime == 0 { lastTime = now }
    }

    func step(now: CFTimeInterval, bounds: CGSize) {
        let dt = max(0, lastTime > 0 ? now - lastTime : 0)
        lastTime = now

        var alive: [Particle] = []
        alive.reserveCapacity(particles.count)

        for var p in particles {
            let age = now - p.birth
            guard age < p.life else { continue }

            // integrate motion
            p.vel.y += gravity * CGFloat(dt)
            p.pos.x += p.vel.x * CGFloat(dt)
            p.pos.y += p.vel.y * CGFloat(dt)
            p.angle += p.spin * CGFloat(dt)

            alive.append(p)
        }
        particles = alive
    }
    
    private var lastTrigger: Int = 0

    func handleTrigger(_ newValue: Int, in size: CGSize, colors: [Color], count: Int) {
        guard newValue != lastTrigger else { return }
        lastTrigger = newValue
        let origin = CGPoint(x: size.width / 2, y: size.height / 4)
        emit(from: origin, count: count, colors: colors)
    }
}

struct ConfettiOverlay: View {
    @Binding var trigger: Int  // bump this to fire a burst

    var colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink]
    var count: Int = 80

    @StateObject private var engine = ConfettiEngine()

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                let now = CACurrentMediaTime()

                // Pure: hand off to engine; no SwiftUI state mutation here
                engine.handleTrigger(trigger, in: size, colors: colors, count: count)

                engine.step(now: now, bounds: size)

                for p in engine.particles {
                    let alpha = max(0, 1 - (now - p.birth) / p.life)
                    context.opacity = alpha

                    var tx = CGAffineTransform(translationX: p.pos.x, y: p.pos.y)
                    tx = tx.rotated(by: p.angle)

                    let w = p.size, h = p.size * 0.6
                    let rect = CGRect(x: -w/2, y: -h/2, width: w, height: h)
                    let path = Path(roundedRect: rect, cornerRadius: w * 0.2).applying(tx)

                    context.fill(path, with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
    }
}




//
//  LinePlot.swift
//  GBG
//
//  Created by Jacob Zeisel on 9/10/25.
//
import SwiftUI
import RHLinePlot

struct GBPlot: View {
    let demoValues: [CGFloat]
    let demoSegments: [Int]
    
    var body: some View {
        RHInteractiveLinePlot(
            values: demoValues,
            occupyingRelativeWidth: 1.0,
            showGlowingIndicator: true,
            lineSegmentStartingIndices: demoSegments,
            didSelectValueAtIndex: { idx in
                //
                //
            },
            customLatestValueIndicator: { EmptyView() },
            valueStickLabel: { value in
                Text(String(format: "%.2f g", value))
                    .font(.caption)
                    .foregroundColor(Color("NormalWhite"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        )
        .frame(height: 160)
        .foregroundColor(Color("SecondaryGold")) // sets line color
        .environment(\.rhLinePlotConfig,
                     RHLinePlotConfig.default.custom { c in
                         c.plotLineWidth = 1.5
                         c.valueStickColor = Color("NormalWhite")
                         c.valueStickTopPadding = 16
                         c.valueStickBottomPadding = 16
                     })
        .padding(.top, 4)
    }
}

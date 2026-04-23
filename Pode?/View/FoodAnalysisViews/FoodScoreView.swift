//
//  FoodScoreView.swift
//  Pode?
//
//  Created by Marlon Ribas on 21/04/26.
//

import SwiftUI

struct ArcShape: Shape {
    
    var startAngle: Double // em graus
    var endAngle: Double   // em graus
    var radiusRatio: CGFloat = 1.0 // 1.0 = máximo possível
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let radius = min(rect.width, rect.height) / 2 * radiusRatio
        
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        
        return path
    }
}

struct FoodScoreView: View {
    
    var score: Int
    
    @State private var displayScore: Int = 0
    
    private var normalized: Double {
        min(max(Double(displayScore) / 100.0, 0), 1)
    }
    
    private var progress: Double {
        Double(score) / 100.0
    }
    
    private let totalAngle: Double = 210
    private let startAngle: Double = 165 // centralizado
    
    private var gradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                HealthColors.negative,
                HealthColors.warning,
                HealthColors.positive
            ]),
            center: .center,
            startAngle: .degrees(180),
            endAngle: .degrees(360)
        )
    }
    
    var body: some View {
        ZStack {
            
            // Base
            ArcShape(
                startAngle: startAngle,
                endAngle: startAngle + totalAngle,
                radiusRatio: 0.8
            )
            .stroke(Color.gray.opacity(0.15), lineWidth: 14)
            
            // Progresso
            ArcShape(
                startAngle: startAngle,
                endAngle: startAngle + totalAngle * normalized,
                radiusRatio: 0.8
            )
            .stroke(
                gradient,
                style: StrokeStyle(lineWidth: 14)
            )
            .animation(.linear(duration: 0.02), value: displayScore)
            
            // Texto
            VStack(spacing: 2) {
                Text("SCORE")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(displayScore)")
                    .font(.title)
                    .bold()
                    .contentTransition(.numericText())
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(height: 120)
        .padding(.bottom, -32)
        .onAppear {
            animateScore()
        }
        .onChange(of: score) { _, _ in
            animateScore()
        }
    }
    
    private func animateScore() {
        let duration = 0.8
        let steps = max(abs(score - displayScore), 1)
        let stepTime = duration / Double(steps)
        
        Task {
            let start = displayScore
            let end = score
            let direction = end > start ? 1 : -1
            
            for i in stride(from: start, to: end, by: direction) {
                try? await Task.sleep(nanoseconds: UInt64(stepTime * 1_000_000_000))
                
                await MainActor.run {
                    displayScore = i + direction
                }
            }
        }
    }
}

#Preview {
    FoodScoreView(score: 100)
        .background(.gray)
}

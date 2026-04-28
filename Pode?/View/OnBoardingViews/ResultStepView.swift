//
//  ResultStepView.swift
//  Pode?
//
//  Created by Marlon Ribas on 28/04/26.
//

import SwiftUI

struct ResultStepView: View {
    let step: OnboardingStep
    let isActive: Bool
 
    @State private var appeared = false
    @State private var scoreValue: Int = 0
    @State private var badgesVisible = [false, false, false]
 
    private let demoScore: Int = 72
 
    private let badges: [(label: String, icon: String, color: Color, detail: String)] = [
        ("Pode", "checkmark.circle.fill", .green, "Adequado para a criança"),
        ("Evitável", "exclamationmark.triangle.fill", .orange, "Consumo com moderação"),
        ("Não pode", "xmark.octagon.fill", .red, "Não recomendado para a idade")
    ]
 
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)
 
            FoodScoreView(score: scoreValue)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)
                .animation(.spring(duration: 0.5), value: appeared)
 
            VStack(spacing: 10) {
                ForEach(Array(badges.enumerated()), id: \.offset) { i, badge in
                    HStack(spacing: 14) {
                        Image(systemName: badge.icon)
                            .font(.title3)
                            .foregroundStyle(badge.color)
                            .frame(width: 28)
 
                        VStack(alignment: .leading, spacing: 2) {
                            Text(badge.label)
                                .font(.subheadline.weight(.semibold))
                            Text(badge.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
 
                        Spacer()
 
                        Text("Ana, 2 anos")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(badge.color.opacity(0.12))
                            .foregroundStyle(badge.color)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .opacity(badgesVisible[i] ? 1 : 0)
                    .offset(x: badgesVisible[i] ? 0 : 32)
                    .animation(
                        .spring(duration: 0.5, bounce: 0.3).delay(0.5 + Double(i) * 0.15),
                        value: badgesVisible[i]
                    )
                }
            }
 
            VStack(spacing: 10) {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.15), value: appeared)
 
                Text(step.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(0.25), value: appeared)
            }
 
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 4)
        .onChange(of: isActive) { _, active in
            if active {
                startAnimations()
            } else {
                resetAnimations()
            }
        }
        .onAppear {
            // Cobre o edge case de já iniciar nesta tab (improvável, mas seguro)
            if isActive { startAnimations() }
        }
    }
 
    private func startAnimations() {
        scoreValue = 0
        appeared = false
        badgesVisible = [false, false, false]
 
        // Um tick de RunLoop para o SwiftUI commitar o estado zerado
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            appeared = true
            scoreValue = demoScore
            for i in badges.indices {
                badgesVisible[i] = true
            }
        }
    }
 
    private func resetAnimations() {
        appeared = false
        scoreValue = 0
        badgesVisible = [false, false, false]
    }
}

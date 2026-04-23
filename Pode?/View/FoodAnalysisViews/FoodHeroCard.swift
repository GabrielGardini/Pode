//
//  FoodHeroCard.swift
//  Pode?
//
//  Created by Marlon Ribas on 23/04/26.
//

import SwiftUI

struct FoodHeroCard: View {
    let food: Food
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(food.name)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        PodeBadge(style: badgeStylePode(for: food.classificacaoGeral))
                        
                        Text(food.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    FoodScoreView(score: food.healthScore.score)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(food.highlights) { item in
                        HighlightRow(highlight: item)
                    }
                }
            }
            
            InfoSection(title: "Resumo principal", systemImage: "heart.fill") {
                VStack(spacing: 12) {
                    KeyValueRow(
                        title: "Calorias / 100 g",
                        value: food.calories.por100g.map {
                            "\(format(Double($0))) g" } ?? "—",
                        emphasizeValue: true
                    )
                    
                    Divider()
                    
                    KeyValueRow(
                        title: "Calorias / porção",
                        value: food.calories.porPorcao.map { "\(format(Double($0))) g" } ?? "—",
                        emphasizeValue: true
                    )
                    
                    Divider()
                    
                    KeyValueRow(
                        title: "Porção",
                        value: food.calories.porcaoG.map { "\(format($0)) g" } ?? "—",
                        emphasizeValue: true
                    )
                }
            }
            
            InfoSection(title: "Interpretação", systemImage: "waveform.path.ecg.text") {
                VStack(spacing: 12) {
                    KeyValueRow(
                        title: "Tipo inferido",
                        value: food.inferredFoodType.label,
                        emphasizeValue: true
                    )
                    
                    Divider()
                    
                    KeyValueRow(
                        title: "Confiança do tipo",
                        value: capitalized(food.inferredFoodType.confidence),
                        emphasizeValue: false
                    )
                    
                    Divider()
                    
                    KeyValueRow(
                        title: "Confiança geral",
                        value: "\(Int(food.confidenceOverall * 100))%",
                        emphasizeValue: true
                    )
                }
            }
        }
    }
    
    private var scoreBadgeStyle: HealthBadge.Style {
        let ratio = Double(food.healthScore.score) / Double(food.healthScore.maxScore)
        if ratio >= 0.7 { return .positive }
        if ratio >= 0.4 { return .neutral }
        return .negative
    }
    
    private func badgeStyle(for text: String) -> HealthBadge.Style {
        switch text.lowercased() {
        case "recomendado":
            return .positive
        case "moderado":
            return .neutral
        default:
            return .negative
        }
    }
    
    private func badgeStylePode(for text: String) -> PodeBadge.Style {
        switch text.lowercased() {
        case "recomendado":
            return .positive
        case "moderado":
            return .neutral
        default:
            return .negative
        }
    }
    
    private func format(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
    
    private func capitalized(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }
}

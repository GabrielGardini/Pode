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
                        Text(capitalized(food.name))
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                                                
                        Text(food.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        FoodScoreView(score: food.healthScore.score)
                        
                        HealthScoreBadge(style: badgeStyleHealthScore(for: food.healthScore.label))
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(food.highlights) { item in
                        HighlightRow(highlight: item)
                    }
                }
            }
            .scrollClipDisabled()
            
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
    
    private func badgeStyleHealthScore(for text: String) -> HealthScoreBadge.Style {
        switch text.lowercased() {
        case "muito_saudavel":
            return .very_positive
        case "saudavel":
            return .positive
        case "moderado":
            return .neutral
        case "pouco_saudavel":
            return .negative
        default:
            return .very_negative
        }
    }
        
    private struct HealthScoreBadge: View {
        enum Style {
            case very_positive
            case positive
            case neutral
            case negative
            case very_negative
            
            var text: String {
                switch self {
                case .very_positive: return "Muito Saudável"
                case .positive: return "Saudável"
                case .neutral: return "Moderado"
                case .negative: return "Pouco Saudável"
                case .very_negative: return "Não Saudável"
                }
            }
            
            var foreground: Color {
                switch self {
                case .very_positive, .positive: return HealthColors.positive
                case .neutral: return HealthColors.warning
                case .very_negative, .negative: return HealthColors.negative
                }
            }
        }
        
        let style: Style
        
        var body: some View {
            Text(style.text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(style.foreground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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

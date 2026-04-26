//
//  FoodHeroCard.swift
//  Pode?
//
//  Created by Marlon Ribas on 23/04/26.
//

import SwiftUI

struct FoodCard: View {
    let food: Food
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(capitalized(food.name))
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                                                
                        Text(capitalized(food.summary))
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
    
    func badgeStyleHealthScore(for text: String) -> HealthScoreBadge.Style {
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
    
    func format(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
    
    func capitalized(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }
}

struct HealthScoreBadge: View {
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

struct KeyValueRow: View {
    let title: String
    let value: String
    let emphasizeValue: Bool
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(emphasizeValue ? .subheadline.weight(.bold) : .subheadline.weight(.semibold))
                .foregroundStyle(emphasizeValue ? Color.accentColor : .primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct HighlightRow: View {
    let highlight: Highlight
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
            
            Text(highlight.title)
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding()
        .frame(width: 140, height: 140, alignment: .leading)
        
        .background(
            LinearGradient(
                colors: [HealthColors.sectionBackground, iconColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch highlight.type.lowercased() {
        case "warning":
            return "exclamationmark.triangle.fill"
        case "positive":
            return "checkmark.circle.fill"
        default:
            return "circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch highlight.type.lowercased() {
        case "warning":
            return HealthColors.warning
        case "positive":
            return HealthColors.positive
        default:
            return .secondary
        }
    }
}

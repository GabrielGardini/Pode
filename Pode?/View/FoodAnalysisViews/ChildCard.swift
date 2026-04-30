//
//  ChildCard.swift
//  Pode?
//
//  Created by Marlon Ribas on 23/04/26.
//

import SwiftUI

struct ChildCard: View {
    
    let child: FoodAnalysisChild
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(displayName)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(Child.ageDisplay(age: child.ageMonths))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                PodeBadge(style: badgeStylePode(for: child.classificacaoGeralCrianca))
            }
            
            InfoSection(title: "Orientação", systemImage: "checklist.checked") {
                HStack(spacing: 10) {
                    if let frequency = child.frequency {
                        Image(systemName: frequency.allowed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(frequency.allowed ? HealthColors.positive : HealthColors.negative)
                            .font(.title3)
                        
                        Text(capitalized(frequency.description))
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
            
            InfoSection(title: "Justificativas", systemImage: "text.bubble.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    if let justifications = child.justifications {
                        ForEach(Array(justifications.enumerated()), id: \.offset) { index, item in
                            BulletLine(text: item)
                            
                            if index < justifications.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            
            if badgeStylePode(for: child.classificacaoGeralCrianca) != .positive {
                InfoSection(title: "Alternativas", systemImage: "leaf.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        if let alternatives = child.alternatives {
                            ForEach(Array(alternatives.enumerated()), id: \.element.id) { index, alternative in
                                HStack(spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(Color.accentColor)
                                    
                                    Text(capitalized(alternative.name))
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                                
                                if index < alternatives.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func badgeStylePode(for text: String) -> PodeBadge.Style {
        switch text.lowercased() {
        case "pode!":
            return .positive
        case "evitável":
            return .neutral
        default:
            return .negative
        }
    }
    
    private var displayName: String {
        child.name.prefix(1).uppercased() + child.name.dropFirst()
    }
}

struct PodeBadge: View {
    enum Style {
        case positive
        case neutral
        case negative
        
        var text: String {
            switch self {
            case .positive: return "Pode!"
            case .neutral: return "Evitável"
            case .negative: return "Não pode!"
            }
        }
        
        var foreground: Color {
            switch self {
            case .positive: return HealthColors.positive
            case .neutral: return HealthColors.warning
            case .negative: return HealthColors.negative
            }
        }
        
        var background: Color {
            switch self {
            case .positive: return HealthColors.positive.opacity(0.12)
            case .neutral: return HealthColors.warning.opacity(0.14)
            case .negative: return HealthColors.negative.opacity(0.12)
            }
        }
    }
    
    let style: Style
    
    var body: some View {
        Text(style.text)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(style.background)
            .clipShape(Capsule())
    }
}

struct BulletLine: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            Text(capitalized(text))
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

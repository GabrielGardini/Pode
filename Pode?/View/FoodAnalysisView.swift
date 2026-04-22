import SwiftUI

struct FoodAnalysisView: View {
    
    let response: FoodAnalysisResponse
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    FoodHeroCard(food: response.food)
                    
                    ForEach(response.children) { child in
                        ChildCard(child: child)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(
                HealthColors.screenBackground
                    .ignoresSafeArea()
            )
            .navigationTitle("Análise")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Food Card

private struct FoodHeroCard: View {
    let food: Food
    
    var body: some View {
        HealthCard {
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
                
                DisclosureGroup {
                    NewInfoSection {
                        VStack(spacing: 12) {
                            KeyValueRow(
                                title: "Calorias / 100 g",
                                value: "\(food.calories.por100g) kcal",
                                emphasizeValue: true
                            )
                            
                            Divider()
                            
                            KeyValueRow(
                                title: "Calorias / porção",
                                value: "\(food.calories.porPorcao) kcal",
                                emphasizeValue: true
                            )
                            
                            Divider()
                            
                            KeyValueRow(
                                title: "Porção",
                                value: "\(format(food.calories.porcaoG)) g",
                                emphasizeValue: true
                            )
                        }
                    }
                } label: {
                    Label {
                        Text("Resumo principal")
                            .fontWeight(.bold)
                    } icon: {
                        Image(systemName: "heart.fill")
                    }
                }
                
                DisclosureGroup {
                    NewInfoSection {
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
                } label: {
                    Label {
                        Text("Interpretação")
                            .fontWeight(.bold)
                    } icon: {
                        Image(systemName: "waveform.path.ecg.text")
                    }
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

// MARK: - Child Card

private struct ChildCard: View {
    let child: FoodAnalysisChild
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(displayName)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(ageText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    HealthBadge(
                        text: child.recommendation.shortText,
                        style: child.recommendation.recommended ? .positive : .negative
                    )
                }
                
                AccentSummaryPanel(
                    title: "Status da recomendação",
                    rows: [
                        .init(
                            label: "Pode consumir",
                            value: child.recommendation.recommended ? "Sim" : "Não"
                        ),
                        .init(
                            label: "Frequência",
                            value: child.frequency.allowed ? "Permitido" : "Não permitido"
                        )
                    ]
                )
                
                InfoSection(title: "Orientação", systemImage: "checklist.checked") {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: child.frequency.allowed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(child.frequency.allowed ? HealthColors.positive : HealthColors.negative)
                            .font(.title3)
                        
                        Text(child.frequency.description)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
                
                InfoSection(title: "Justificativas", systemImage: "text.bubble.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(child.justifications.enumerated()), id: \.offset) { index, item in
                            BulletLine(text: item)
                            
                            if index < child.justifications.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                
                InfoSection(title: "Alternativas", systemImage: "leaf.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(child.alternatives.enumerated()), id: \.element.id) { index, alternative in
                            HStack(spacing: 10) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color.accentColor)
                                
                                Text(alternative.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            
                            if index < child.alternatives.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var displayName: String {
        child.name.prefix(1).uppercased() + child.name.dropFirst()
    }
    
    private var ageText: String {
        if child.ageMonths < 24 {
            return "\(child.ageMonths) meses"
        }
        
        let years = child.ageMonths / 12
        let months = child.ageMonths % 12
        
        if months == 0 {
            return years == 1 ? "1 ano" : "\(years) anos"
        }
        
        let yearText = years == 1 ? "1 ano" : "\(years) anos"
        let monthText = months == 1 ? "1 mês" : "\(months) meses"
        return "\(yearText) e \(monthText)"
    }
}

// MARK: - Reusable UI

private struct HealthCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(HealthColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(HealthColors.cardStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }
}

private struct NewInfoSection<Content: View>: View {
//    let title: String
//    let systemImage: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
//            Label {
//                Text(title)
//                    .font(.headline)
//                    .foregroundStyle(.primary)
//            } icon: {
//                Image(systemName: systemImage)
//                    .foregroundStyle(Color.accentColor)
//            }
//            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HealthColors.sectionBackground)
            )
        }
    }
}

private struct InfoSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HealthColors.sectionBackground)
            )
        }
    }
}

private struct AccentSummaryPanel: View {
    struct Row: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }
    
    let title: String
    let rows: [Row]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.accentColor)
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    KeyValueRow(
                        title: row.label,
                        value: row.value,
                        emphasizeValue: true
                    )
                    
                    if index < rows.count - 1 {
                        Divider()
                            .overlay(HealthColors.accentSoft)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(HealthColors.accentPanelBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(HealthColors.accentSoft, lineWidth: 1)
        )
    }
}

private struct KeyValueRow: View {
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

private struct HighlightRow: View {
    let highlight: Highlight
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                        
            Text(highlight.title)
                .font(.callout)
                .fontWeight(.bold)
        }
        .padding(20)
        .frame(width: 150, height: 140, alignment: .leading)
        .background(HealthColors.sectionBackground)
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
        case "info":
            return "info.circle.fill"
        default:
            return "circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch highlight.type.lowercased() {
        case "warning":
            return HealthColors.warning
        case "info":
            return Color.accentColor
        default:
            return .secondary
        }
    }
}

private struct BulletLine: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

private struct PodeBadge: View {
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
            .font(.headline)
            .foregroundStyle(style.foreground)
    }
}

private struct HealthBadge: View {
    enum Style {
        case positive
        case neutral
        case negative
        
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
    
    let text: String
    let style: Style
    
    var body: some View {
        Text(text)
            .font(.footnote.weight(.bold))
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(style.background)
            .clipShape(Capsule())
    }
}

enum HealthColors {
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let sectionBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    static let cardStroke = Color.primary.opacity(0.06)
    
    static let accentPanelBackground = Color.accentColor.opacity(0.08)
    static let accentSoft = Color.accentColor.opacity(0.18)
    
    static let positive = Color(red: 0.10, green: 0.67, blue: 0.34)
    static let warning = Color(red: 0.95, green: 0.58, blue: 0.13)
    static let negative = Color(red: 0.89, green: 0.23, blue: 0.29)
}

#Preview {
    FoodAnalysisView(response: mockResponse)
}

private let mockResponse = FoodAnalysisResponse(
    food: Food(
        name: "Chocolate",
        summary: "Alimento rico em açúcar e gordura, consumo deve ser moderado.",
        classificacaoGeral: "Evitar",
        calories: Calories(
            por100g: 540,
            porPorcao: 108,
            porcaoG: 20
        ),
        highlights: [
            Highlight(type: "negativo", title: "Alto em açúcar"),
            Highlight(type: "negativo", title: "Rico em gordura"),
            Highlight(type: "positivo", title: "Fonte de energia rápida")
        ],
        healthScore: HealthScore(
            score: 45,
            maxScore: 100,
            label: "Baixo"
        ),
        inferredFoodType: InferredFoodType(
            label: "Doce industrializado",
            confidence: "Alta"
        ),
        confidenceOverall: 0.92
    ),
    children: [
        FoodAnalysisChild(
            name: "João",
            ageMonths: 16,
            recommendation: Recommendation(
                recommended: false,
                shortText: "Não recomendado para esta idade"
            ),
            justifications: [
                "Alto teor de açúcar",
                "Baixo valor nutricional"
            ],
            frequency: Frequency(
                allowed: false,
                description: "Evitar completamente"
            ),
            alternatives: [
                Alternative(name: "Frutas"),
                Alternative(name: "Iogurte natural")
            ]
        ),
        FoodAnalysisChild(
            name: "Maria",
            ageMonths: 36,
            recommendation: Recommendation(
                recommended: true,
                shortText: "Pode consumir ocasionalmente"
            ),
            justifications: [
                "Pode ser consumido com moderação"
            ],
            frequency: Frequency(
                allowed: true,
                description: "1x por semana"
            ),
            alternatives: [
                Alternative(name: "Chocolate 70%"),
                Alternative(name: "Frutas secas")
            ]
        )
    ]
)

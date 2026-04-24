import SwiftUI

//struct FoodAnalysisView: View {
//
//    let response: FoodAnalysisResponse
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                LazyVStack(spacing: 16) {
//
//                    FoodHeroCard(food: response.food)
//
//                    ForEach(response.children) { child in
//                        ChildCard(child: child)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 20)
//            }
//            .background(
//                HealthColors.screenBackground
//                    .ignoresSafeArea()
//            )
//            .navigationTitle("Análise")
//            .navigationBarTitleDisplayMode(.large)
//        }
//    }
//}

struct FoodAnalysisView: View {
    
    let response: FoodAnalysisResponse
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    footer: Text("As informações apresentadas não substituem orientações ou instruções médicas. Para mais detalhes, consulte o [Guia Alimentar para a População Brasileira](https://bvsms.saude.gov.br/bvs/publicacoes/guia_alimentar_populacao_brasileira_2ed.pdf)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                ) {
                    FoodHeroCard(food: response.food)
                        .padding(8)
                }
                
                
                ForEach(response.children) { child in
                    Section {
                        ChildCard(child: child)
                            .padding(8)
                    }
                }
            }
            .navigationTitle("Análise")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Reusable UI

struct HealthCard<Content: View>: View {
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

struct NewInfoSection<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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

struct InfoSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Image(systemName: systemImage)
                    .font(.body)
                    .foregroundStyle(Color.accentColor)
                
                Text(title)
                    .font(.headline)
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

struct AccentSummaryPanel: View {
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

struct BulletLine: View {
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

struct HealthBadge: View {
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
            classificacaoGeralCrianca: "Não pode!",
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
            classificacaoGeralCrianca: "Pode!",
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


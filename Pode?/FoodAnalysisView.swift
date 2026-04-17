import SwiftUI

struct FoodAnalysisView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel

    init(json: String?) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(json: json ?? ""))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .tint(.accentColor)
                        .navigationTitle("Análise")

                case .failed(let message):
                    ContentUnavailableView(
                        "Não foi possível carregar",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    .navigationTitle("Análise")

                case .loaded(let response):
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            FoodHeroCard(food: response.food)

                            ForEach(response.children) { child in
                                ChildCard(child: child)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .background(HealthColors.screenBackground.ignoresSafeArea())
                    .navigationTitle("Análise")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
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
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)

                            Text(food.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.accentColor)
                    }

                    HStack(spacing: 8) {
                        HealthBadge(
                            text: food.classificacaoGeral,
                            style: badgeStyle(for: food.classificacaoGeral)
                        )

                        HealthBadge(
                            text: "\(food.healthScore.score)/\(food.healthScore.maxScore)",
                            style: scoreBadgeStyle
                        )
                    }
                }

                AccentSummaryPanel(
                    title: "Resumo principal",
                    rows: [
                        .init(label: "Calorias / 100 g", value: "\(food.calories.por100g) kcal"),
                        .init(label: "Calorias / porção", value: "\(food.calories.porPorcao) kcal"),
                        .init(label: "Porção", value: "\(format(food.calories.porcaoG)) g")
                    ]
                )

                InfoSection(title: "Alertas", systemImage: "exclamationmark.shield.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(food.highlights) { item in
                            HighlightRow(highlight: item)
                        }
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
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.title3)

            Text(highlight.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            Spacer()
        }
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

private enum HealthColors {
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
    FoodAnalysisView(json: """
    {
      "food": {
        "name": "KitKat",
        "summary": "Chocolate ultraprocessado com alto teor de açúcar, alta densidade calórica e presença de gorduras, com baixo valor nutricional.",
        "classificacao_geral": "Evitável",
        "calories": {
          "por_100g": 534,
          "por_porcao": 219,
          "porcao_g": 41.5
        },
        "highlights": [
          {
            "type": "warning",
            "title": "Altíssimo teor de açúcar"
          },
          {
            "type": "warning",
            "title": "Ultraprocessado"
          },
          {
            "type": "warning",
            "title": "Alta densidade calórica"
          }
        ],
        "health_score": {
          "score": 20,
          "max_score": 100,
          "label": "nao_saudavel"
        },
        "inferred_food_type": {
          "label": "Chocolate industrializado com wafer",
          "confidence": "alta"
        },
        "confidence_overall": 0.85
      },
      "children": [
        {
          "name": "joao",
          "age_months": 37,
          "recommendation": {
            "recommended": false,
            "short_text": "Não pode!"
          },
          "justifications": [
            "Contém açúcar em alta quantidade, inadequado para crianças pequenas segundo o Guia Alimentar",
            "Alimento ultraprocessado, não recomendado para menores de 2 anos e deve ser evitado mesmo após essa idade",
            "Possível presença de derivados de milho, incompatível com a restrição informada"
          ],
          "frequency": {
            "allowed": false,
            "description": "Não recomendado devido ao alto teor de açúcar e risco potencial relacionado à alergia."
          },
          "alternatives": [
            {
              "name": "Frutas frescas (banana, maçã, pera)"
            },
            {
              "name": "Panqueca caseira sem açúcar"
            },
            {
              "name": "Iogurte natural com fruta"
            }
          ]
        },
        {
          "name": "maria",
          "age_months": 7,
          "recommendation": {
            "recommended": false,
            "short_text": "Não pode!"
          },
          "justifications": [
            "Contém açúcar, que é proibido para crianças entre 6 e 12 meses",
            "Alimento ultraprocessado, proibido nessa faixa etária",
            "Alta densidade calórica e baixa qualidade nutricional"
          ],
          "frequency": {
            "allowed": false,
            "description": "Totalmente proibido para essa idade segundo o Guia Alimentar para crianças menores de 2 anos."
          },
          "alternatives": [
            {
              "name": "Frutas amassadas (banana, pera, maçã cozida)"
            },
            {
              "name": "Purê de legumes (abóbora, batata, cenoura)"
            },
            {
              "name": "Papa caseira sem açúcar"
            }
          ]
        }
      ]
    }
    """)
    .tint(.pink)
}


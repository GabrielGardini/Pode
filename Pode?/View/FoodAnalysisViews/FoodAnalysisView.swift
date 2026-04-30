import SwiftUI

struct FoodAnalysisView: View {
    
    let response: FoodAnalysisResponse
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    footer: Text("As informações apresentadas não substituem orientações ou instruções médicas. Para mais detalhes, consulte o [Guia Alimentar para a População Brasileira](https://bvsms.saude.gov.br/bvs/publicacoes/guia_alimentar_populacao_brasileira_2ed.pdf).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                ) {
                    FoodCard(food: response.food)
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

enum HealthColors {
    static let sectionBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    
    static let accentPanelBackground = Color.accentColor.opacity(0.08)
    static let accentSoft = Color.accentColor.opacity(0.18)
    
    static let positive = Color(red: 0.10, green: 0.67, blue: 0.34)
    static let warning = Color(red: 0.95, green: 0.58, blue: 0.13)
    static let negative = Color(red: 0.89, green: 0.23, blue: 0.29)
}

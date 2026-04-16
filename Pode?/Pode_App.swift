import SwiftUI
import SwiftData

@main
struct Pode_App: App {
    var body: some Scene {
        WindowGroup {
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
            """).tint(.green)       }
        .modelContainer(for: [Child.self])
    }
}

import Foundation
import SwiftUI

struct ContentItem: Codable {
    let type: String
    let text: String
}

struct OutputItem: Codable {
    let content: [ContentItem]
}

struct OpenAIResponse: Codable {
    let output: [OutputItem]
}

func request(description: String, table: String, children: [Child]) async -> String {
    let url = URL(string: "https://api.openai.com/v1/responses")!
    
    // Monta string detalhada das crianças: nome, idade e alergias
    let formattedChildren: String = {
        guard !children.isEmpty else { return "[]" }
        var parts: [String] = []
        for child in children {
            // Assumindo que `Child` tenha `name: String?`, `ageMonths: Int?`, `ageYears: Int?`, `allergies: [String]?`
            let name: String = {
                // Handle both optional and non-optional name gracefully
                let raw = (child.name as String?) ?? ""
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? "Sem nome" : trimmed
            }()

            let ageMonths: String? = {
                // Support both optional and non-optional Int for age
                if let ageOpt = (child.age as Int?) {
                    return "\(ageOpt) meses"
                }
                return nil
            }()

            let allergiesList: String = {
                // Support both optional and non-optional arrays for allergies
                let rawAllergies = (child.allergies as [String]?) ?? []
                let cleaned = rawAllergies
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                if !cleaned.isEmpty {
                    return cleaned.joined(separator: ", ")
                }
                return "nenhuma conhecida"
            }()

            let entry = "{ name: \"\(name)\", age: \"\(ageMonths ?? "desconhecida")\", allergies: \"\(allergiesList)\" }"
            parts.append(entry)
        }
        return "[\n  " + parts.joined(separator: ",\n  ") + "\n]"
    }()
    
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    if let apiKey = SecretManager.apiKey as? String {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let system_prompt = """
    Você é um especialista em nutrição infantil.

    Analise um alimento com base em:
    - tabela nutricional (OCR, opcional)
    - descrição do alimento (opcional)

    ---

    ### Base obrigatória
    Use EXCLUSIVAMENTE:
    - Guia Alimentar para a População Brasileira
    - Guia Alimentar para Crianças Brasileiras Menores de 2 Anos

    ---

    ### Prioridade de decisão
    1. Alimentos proibidos (ABSOLUTO)
    2. Alergias
    3. Diretrizes oficiais
    4. Tabela/descrição (inferência)

    ---

    ### Idade das crianças

    - age_months: usar quando < 24 meses
    - age_years: usar quando ≥ 2 anos

    Regra:
    → Converta internamente para meses quando necessário
    → Todas as decisões devem considerar a idade individual de cada criança

    ---

    ### Alimentos proibidos por idade

    0–6 meses:
    - qualquer alimento ou líquido (exceto leite materno)

    6–12 meses:
    - açúcar e derivados
    - bebidas açucaradas ou artificiais
    - ultraprocessados
    - mel
    - estimulantes

    12–24 meses:
    - açúcar e derivados
    - bebidas açucaradas ou artificiais
    - ultraprocessados

    Regra:
    → Se houver item proibido → "Não pode!"

    ---

    ### Derivados (detecção)
    - açúcar: glicose, frutose, sacarose, maltodextrina, xarope
    - leite: lactose, caseína, whey

    ---

    ### Regras de análise
    - Seja conservador
    - Considere erros de OCR
    - Não invente dados
    - Use descrição como apoio quando a tabela for incompleta
    - Avalie açúcar, sódio e processamento

    ---

    ### Classificação por processamento
    - in natura
    - minimamente processado
    - processado
    - ultraprocessado

    ---

    ### Classificação geral

    Escolha UMA:

    "Pode!"
    - alimento seguro e de boa qualidade
    - sem açúcar adicionado, baixo sódio

    "Evitável"
    - não proibido, mas de baixa qualidade

    "Não pode!"
    - proibido, ultraprocessado (<2 anos) ou com risco

    ---

    ### Regras obrigatórias

    - Proibido → "Não pode!"
    - Alergia → "Não pode!"
    - Ultraprocessado:
      - <2 anos → "Não pode!"
      - outros → mínimo "Evitável"
    - Incerteza → nunca "Pode!"

    ---

    ### Consistência

    - "Não pode!" → score ≤ 30
    - "Evitável" → 20–60
    - "Pode!" → ≥ 60

    ---

    ### Entrada

    Descrição:
    {{\(description)}}

    Tabela (OCR):
    {{\(table)}}

    Crianças:
    {{\(formattedChildren)}}

    ---

    ### Saída (JSON)

    {
      "food": {
        "name": "nome ou desconhecido",
        "summary": "resumo direto",
        "classificacao_geral": "Pode! | Evitável | Não pode!",
        "calories": {
          "por_100g": number | null,
          "por_porcao": number | null,
          "porcao_g": number | null
        },
        "highlights": [
          { "type": "warning | positive", "title": "curto" }
        ],
        "health_score": {
          "score": 0-100,
          "max_score": 100,
          "label": "muito_saudavel | saudavel | moderado | pouco_saudavel | nao_saudavel"
        },
        "inferred_food_type": {
          "label": "tipo provável",
          "confidence": "alta | media | baixa"
        },
        "confidence_overall": 0.0
      },
      "children": [
        {
          "name": "string",
          "age_months": number | null,
          "recommendation": {
            "recommended": true | false,
            "short_text": "mensagem curta"
          },
          "justifications": ["motivos"],
          "frequency": {
            "allowed": true | false,
            "description": "explicação"
          },
          "alternatives": [
            { "name": "alternativa saudável" }
          ]
        }
      ]
    }

    ---

    ### Regras finais

    - Apenas o JSON, não envie nenhuma outra palavra fora do objeto
    - NÃO ESCREVER A PALAVRA JSON ANTES DO OBJETO
    - Não inventar dados (use null)
    - Máx:
      - 3 highlights
      - 3 alternativas
    - Se incerteza:
      - reduzir score
      - confidence baixa
    - Alternativas:
      - adequadas à idade
      - in natura ou minimamente processadas

    """
    

    
    let jsonBody: [String: Any] = [
        "model": "gpt-4o-mini-2024-07-18",
        "input": system_prompt
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        if let text = decoded.output.first?.content.first?.text {
            print("Texto da resposta: \(text)")
            return text
            
        } else {
            return "Texto não encontrado"
        }
    } catch {
        return "Erro ao decodificar JSON: \(error)"
    }
}


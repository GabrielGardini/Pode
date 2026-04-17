import Foundation

struct FoodAnalysisResponse: Codable {
    let food: Food
    let children: [FoodAnalysisChild]
}

struct Food: Codable {
    let name: String
    let summary: String
    let classificacaoGeral: String
    let calories: Calories
    let highlights: [Highlight]
    let healthScore: HealthScore
    let inferredFoodType: InferredFoodType
    let confidenceOverall: Double

    enum CodingKeys: String, CodingKey {
        case name
        case summary
        case classificacaoGeral = "classificacao_geral"
        case calories
        case highlights
        case healthScore = "health_score"
        case inferredFoodType = "inferred_food_type"
        case confidenceOverall = "confidence_overall"
    }
}

struct Calories: Codable {
    let por100g: Int
    let porPorcao: Int
    let porcaoG: Double

    enum CodingKeys: String, CodingKey {
        case por100g = "por_100g"
        case porPorcao = "por_porcao"
        case porcaoG = "porcao_g"
    }
}

struct Highlight: Codable, Identifiable {
    var id: String { title }
    let type: String
    let title: String
}

struct HealthScore: Codable {
    let score: Int
    let maxScore: Int
    let label: String

    enum CodingKeys: String, CodingKey {
        case score
        case maxScore = "max_score"
        case label
    }
}

struct InferredFoodType: Codable {
    let label: String
    let confidence: String
}

struct FoodAnalysisChild: Codable, Identifiable {
    var id: String { name }
    let name: String
    let ageMonths: Int
    let recommendation: Recommendation
    let justifications: [String]
    let frequency: Frequency
    let alternatives: [Alternative]

    enum CodingKeys: String, CodingKey {
        case name
        case ageMonths = "age_months"
        case recommendation
        case justifications
        case frequency
        case alternatives
    }
}

struct Recommendation: Codable {
    let recommended: Bool
    let shortText: String

    enum CodingKeys: String, CodingKey {
        case recommended
        case shortText = "short_text"
    }
}

struct Frequency: Codable {
    let allowed: Bool
    let description: String
}

struct Alternative: Codable, Identifiable {
    var id: String { name }
    let name: String
}

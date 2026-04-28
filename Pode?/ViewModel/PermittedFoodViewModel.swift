import SwiftUI
import SwiftData

// MARK: - Models
public struct ChildPermittedFood: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var monthsOld: Int
    
    public init(id: UUID = UUID(), name: String, monthsOld: Int) {
        self.id = id
        self.name = name
        self.monthsOld = monthsOld
    }
}

public struct PermittedFood: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var notes: String?
    
    public init(id: UUID = UUID(), name: String, notes: String? = nil) {
        self.id = id
        self.name = name
        self.notes = notes
    }
}

public struct MonthlyPermission: Identifiable, Hashable {
    public let id: UUID
    public var month: Int
    public var endMonth: Int?
    public var permittedFoods: [PermittedFood]
    
    public init(
        id: UUID = UUID(),
        month: Int,
        endMonth: Int? = nil,
        permittedFoods: [PermittedFood]
    ) {
        self.id = id
        self.month = month
        self.endMonth = endMonth
        self.permittedFoods = permittedFoods
    }
    
    public var title: String {
        if let endMonth, endMonth != month {
            return "\(month) a \(endMonth) meses"
        } else {
            return "\(month) meses"
        }
    }
    
    public func contains(month childMonth: Int) -> Bool {
        let end = endMonth ?? month
        return childMonth >= month && childMonth <= end
    }
}

// MARK: - ViewModel
@MainActor
@Observable
public final class PermittedFoodViewModel {

    public private(set) var timeline: [MonthlyPermission]
    var selectedChild: Child?
    
    public init() {
        self.timeline = [
            MonthlyPermission(
                month: 0,
                endMonth: 5,
                permittedFoods: [
                    PermittedFood(
                        name: "🍼 Leite materno exclusivo",
                        notes: "Até 6 meses, não oferecer água, chás, sucos, frutas, papinhas ou outros alimentos."
                    ),
                    PermittedFood(
                        name: "🥛 Fórmula infantil, se indicada",
                        notes: "Usar apenas quando necessário e com orientação profissional."
                    )
                ]
            ),
            
            MonthlyPermission(
                month: 6,
                permittedFoods: [
                    PermittedFood(
                        name: "🍼 Leite materno em livre demanda",
                        notes: "Continuar amamentando sempre que a criança quiser."
                    ),
                    PermittedFood(
                        name: "🍎 Frutas",
                        notes: "Oferecer amassadas, raspadas ou em pedaços seguros. Pode entrar no lanche da manhã e da tarde."
                    ),
                    PermittedFood(
                        name: "💧 Água",
                        notes: "Oferecer água própria para consumo ao longo do dia."
                    ),
                    PermittedFood(
                        name: "🍚 Cereais, raízes e tubérculos",
                        notes: "Exemplos: arroz, aveia, milho, batata, batata-doce, mandioca e inhame."
                    ),
                    PermittedFood(
                        name: "🫘 Feijões e outras leguminosas",
                        notes: "Exemplos: feijão, lentilha, ervilha e grão-de-bico."
                    ),
                    PermittedFood(
                        name: "🥦 Legumes e verduras",
                        notes: "Oferecer variedade de cores, sabores e texturas."
                    ),
                    PermittedFood(
                        name: "🍗 Carnes e ovos",
                        notes: "Carnes bem cozidas, picadas ou desfiadas. Ovos bem cozidos."
                    ),
                    PermittedFood(
                        name: "🥄 Comida amassada com garfo",
                        notes: "Não liquidificar nem peneirar. Começar com pequenas quantidades."
                    )
                ]
            ),
            
            MonthlyPermission(
                month: 7,
                endMonth: 8,
                permittedFoods: [
                    PermittedFood(
                        name: "🍼 Leite materno em livre demanda",
                        notes: "Continuar oferecendo sempre que a criança quiser."
                    ),
                    PermittedFood(
                        name: "🍎 Frutas",
                        notes: "Manter nos lanches da manhã e da tarde."
                    ),
                    PermittedFood(
                        name: "🍛 Almoço e jantar completos",
                        notes: "Prato com cereal/raiz/tubérculo, feijão, legumes/verduras e carne ou ovo."
                    ),
                    PermittedFood(
                        name: "🍽️ Alimentos menos amassados ou bem picados",
                        notes: "Ajustar a textura conforme a aceitação da criança."
                    ),
                    PermittedFood(
                        name: "💧 Água",
                        notes: "Oferecer ao longo do dia."
                    )
                ]
            ),
            
            MonthlyPermission(
                month: 9,
                endMonth: 11,
                permittedFoods: [
                    PermittedFood(
                        name: "🍼 Leite materno em livre demanda",
                        notes: "Ainda é recomendado manter a amamentação."
                    ),
                    PermittedFood(
                        name: "🍎 Frutas",
                        notes: "Continuar nos lanches."
                    ),
                    PermittedFood(
                        name: "🍛 Comida da família",
                        notes: "Desde que seja uma comida saudável, com pouco sal e sem ultraprocessados."
                    ),
                    PermittedFood(
                        name: "🍚 Cereais, raízes e tubérculos",
                        notes: "Exemplos: arroz, macarrão simples, batata, mandioca, inhame e milho."
                    ),
                    PermittedFood(
                        name: "🫘 Feijões",
                        notes: "Fonte importante de ferro, zinco, fibras e proteínas."
                    ),
                    PermittedFood(
                        name: "🥦 Legumes e verduras",
                        notes: "Oferecer todos os dias, variando cores e preparos."
                    ),
                    PermittedFood(
                        name: "🍗 Carnes e ovos",
                        notes: "Carnes podem ser desfiadas. Alimentos já podem vir mais picados, na consistência da família."
                    ),
                    PermittedFood(
                        name: "💧 Água",
                        notes: "Oferecer ao longo do dia."
                    )
                ]
            ),
            
            MonthlyPermission(
                month: 12,
                endMonth: 24,
                permittedFoods: [
                    PermittedFood(
                        name: "🍼 Leite materno até 2 anos ou mais",
                        notes: "Pode continuar sendo oferecido sempre que a criança quiser."
                    ),
                    PermittedFood(
                        name: "🍛 Comida da família",
                        notes: "A criança pode comer a mesma comida da família, com ajustes de tamanho e textura."
                    ),
                    PermittedFood(
                        name: "🍞 Café da manhã",
                        notes: "Exemplos: fruta, aveia, cuscuz, pão caseiro, batata-doce, mandioca ou inhame."
                    ),
                    PermittedFood(
                        name: "🍽️ Almoço e jantar completos",
                        notes: "Prato com cereal/raiz/tubérculo, feijão, legumes/verduras e carne ou ovo."
                    ),
                    PermittedFood(
                        name: "🍎 Lanches com fruta",
                        notes: "Também pode alternar com cereais, raízes ou tubérculos conforme o hábito da família."
                    ),
                    PermittedFood(
                        name: "💧 Água",
                        notes: "Preferir água em vez de sucos, refrigerantes ou bebidas adoçadas."
                    ),
                    PermittedFood(
                        name: "🚫 Evitar açúcar",
                        notes: "Não oferecer açúcar nem produtos com açúcar antes dos 2 anos."
                    ),
                    PermittedFood(
                        name: "🚫 Não oferecer ultraprocessados",
                        notes: "Evitar biscoitos recheados, salgadinhos, refrigerantes, macarrão instantâneo, nuggets, salsicha e similares."
                    )
                ]
            )
        ]
    }
}

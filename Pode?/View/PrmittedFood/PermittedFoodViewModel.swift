import SwiftUI
#if canImport(SwiftData)
import SwiftData
#endif

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
    public var month: Int  // 0..24+
    public var permittedFoods: [PermittedFood]

    public init(id: UUID = UUID(), month: Int, permittedFoods: [PermittedFood]) {
        self.id = id
        self.month = month
        self.permittedFoods = permittedFoods
    }
}

// MARK: - ViewModel
@MainActor
@Observable
public final class PermittedFoodViewModel {
    public private(set) var children: [ChildPermittedFood] = []
    public private(set) var timeline: [MonthlyPermission]
    public var selectedChild: ChildPermittedFood?

    public init() {
        // Build timeline 0..24 months with placeholder foods (domain guidance)
        var items: [MonthlyPermission] = []
        for m in 0...24 {
            let foods: [PermittedFood]
            switch m {
            case 0...3:
                foods = [PermittedFood(name: "Leite materno / fórmula", notes: "Exclusivo.")]
            case 4:
                foods = [
                    PermittedFood(name: "Papinhas introdutórias", notes: "Texturas suaves."),
                    PermittedFood(name: "Frutas amassadas")
                ]
            case 5...6:
                foods = [
                    PermittedFood(name: "Legumes cozidos"),
                    PermittedFood(name: "Cereais sem açúcar")
                ]
            case 7...8:
                foods = [
                    PermittedFood(name: "Carnes bem cozidas", notes: "Desfiadas/amexadas."),
                    PermittedFood(name: "Ovos bem cozidos")
                ]
            case 9...12:
                foods = [
                    PermittedFood(name: "Queijos pasteurizados"),
                    PermittedFood(name: "Iogurte natural")
                ]
            default:
                foods = [PermittedFood(name: "Variedade ampliada", notes: "Ajuste texturas.")]
            }
            items.append(MonthlyPermission(month: m, permittedFoods: foods))
        }
        self.timeline = items
    }

    // MARK: - Data Loading
    /// Loads children from the app database.
    /// If SwiftData `ModelContext` is available in the caller, pass it here to fetch real data.
    /// If no children are found, `children` will be an empty array and `selectedChild` will be nil.
    #if canImport(SwiftData)
    public func loadChildren(from context: ModelContext) {
        do {
            // Fetch all Child entities from SwiftData
            var descriptor = FetchDescriptor<Child>()
            // Example sort: by birthDate ascending (oldest first). Adjust if you prefer by name.
            descriptor.sortBy = [
                .init(\.birthDate, order: .forward),
                .init(\.name, order: .forward)
            ]
            let results = try context.fetch(descriptor)

            // Map to the lightweight view model type used by the UI
            let mapped: [ChildPermittedFood] = results.map { child in
                ChildPermittedFood(
                    name: child.name,
                    monthsOld: child.age
                )
            }

            self.children = mapped
            self.selectedChild = mapped.first
        } catch {
            // On failure, clear state to safe defaults
            self.children = []
            self.selectedChild = nil
            #if DEBUG
            print("[PermittedFoodViewModel] Failed to fetch children: \(error)")
            #endif
        }
    }
    #else
    public func loadChildrenFromDatabase() {
        // SwiftData not available in this target. Implement your database fetch here
        // and assign to `children` and `selectedChild`.
        self.children = []
        self.selectedChild = nil
    }
    #endif
}


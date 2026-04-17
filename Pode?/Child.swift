import Foundation
import SwiftData

@Model
final class Child {
    var name: String
    var birthDate: Date
    var allergies: [String]
    var createdAt: Date

    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month], from: birthDate, to: now)
        return max(0, components.month ?? 0)
    }

    init(name: String, birthDate: Date, allergies: [String], createdAt: Date = .now) {
        self.name = name
        self.birthDate = birthDate
        self.allergies = allergies
        self.createdAt = createdAt
    }
}

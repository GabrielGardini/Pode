import Foundation
import SwiftData

@Model
final class Child {
    var name: String
    var birthDate: Date
    var createdAt: Date

    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month], from: birthDate, to: now)
        return max(0, components.month ?? 0)
    }

    init(name: String, birthDate: Date, createdAt: Date = .now) {
        self.name = name
        self.birthDate = birthDate
        self.createdAt = createdAt
    }
    
    static func ageDisplay(age: Int) -> String {
        if age < 12 {
            let monthText = age == 1 ? "mês" : "meses"
            return "\(age) \(monthText)"
        }
        
        let years = age / 12
        
        if years >= 2 {
            return "\(years) anos"
        }
        
        let months = age % 12
        
        let yearText = years == 1 ? "ano" : "anos"
        
        if months == 0 {
            return "\(years) \(yearText)"
        }
        
        let monthText = months == 1 ? "mês" : "meses"
        return "\(years) \(yearText) e \(months) \(monthText)"
    }
}

import Foundation
import SwiftData

@Model
final class Crianca {
    var id: UUID
    var nome: String
    var dataNascimento: Date
    var info: String
    var createdAt: Date

    var idade: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: dataNascimento, to: now)
        return max(0, components.year ?? 0)
    }

    init(id: UUID = UUID(), nome: String, dataNascimento: Date, info: String, createdAt: Date = .now) {
        self.id = id
        self.nome = nome
        self.dataNascimento = dataNascimento
        self.info = info
        self.createdAt = createdAt
    }
}

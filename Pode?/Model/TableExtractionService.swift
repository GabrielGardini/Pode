//
//  TableExtractionService.swift
//  Pode?
//
//  Created by Marlon Ribas on 19/04/26.
//

import Foundation
import Vision

enum AppError: Error, LocalizedError {
    case noDocument
    case noTable
    
    var errorDescription: String? {
        switch self {
        case .noDocument:
            return "Nenhum documento detectado na imagem."
        case .noTable:
            return "Nenhuma tabela encontrada no documento."
        }
    }
}

struct ParsedTable {
    let headers: [String]?
    let rows: [[String]]
    
    var formattedString: String {
        let allRows = [headers ?? []] + rows
        
        var columnWidths: [Int] = []
        for row in allRows {
            for (i, cell) in row.enumerated() {
                if i >= columnWidths.count {
                    columnWidths.append(cell.count)
                } else {
                    columnWidths[i] = max(columnWidths[i], cell.count)
                }
            }
        }
        
        func formatRow(_ row: [String]) -> String {
            return row.enumerated().map { index, cell in
                let padding = columnWidths[index] - cell.count
                return cell + String(repeating: " ", count: padding)
            }.joined(separator: " | ")
        }
        
        var lines: [String] = []
        
        if let headers = headers {
            lines.append(formatRow(headers))
            let separator = columnWidths.map { String(repeating: "-", count: $0) }
                .joined(separator: "-+-")
            lines.append(separator)
        }
        
        for row in rows {
            lines.append(formatRow(row))
        }
        
        return lines.joined(separator: "\n")
    }
}

struct TableExtractionService {
    
    func extractAndParseTable(from imageData: Data) async throws -> ParsedTable {
        let table = try await extractTable(from: imageData)
        return parseTableGeneric(table)
    }
    
    private func extractTable(from image: Data) async throws -> DocumentObservation.Container.Table {
        let request = RecognizeDocumentsRequest()
        let observations = try await request.perform(on: image)
        
        guard let document = observations.first?.document else {
            throw AppError.noDocument
        }
        
        guard let table = document.tables.first else {
            throw AppError.noTable
        }
        
        return table
    }
    
    private func parseTableGeneric(_ table: DocumentObservation.Container.Table) -> ParsedTable {
        var rows: [[String]] = []
        
        for row in table.rows {
            var parsedRow: [String] = []
            for cell in row {
                let text = cell.content.text.transcript
                let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
                parsedRow.append(cleaned)
            }
            rows.append(parsedRow)
        }
        
        let headers = rows.first
        let dataRows = Array(rows.dropFirst())
        
        return ParsedTable(headers: headers, rows: dataRows)
    }
}

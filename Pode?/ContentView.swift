//
//  ContentView.swift
//  Pode?
//
//  Created by Gabriel Gardini on 13/04/26.
//

import SwiftUI
import Combine
import Vision
import AVFoundation

enum AppError: Error {
    case noDocument
    case noTable
}

struct ParsedTable {
    let headers: [String]?
    let rows: [[String]]
}

struct ContentView: View {
    
    @State private var scannedText: String = ""
    @State private var presentScanner: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Toque em 'Ler Tabela' para capturar o texto da tabela nutricional.")
                    .padding()
            }
            .padding()
            .navigationTitle("Pode?")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentScanner = true
                    } label: {
                        Label("Ler Tabela", systemImage: "camera.viewfinder")
                    }
                }
            }
        }
        .sheet(isPresented: $presentScanner) {
            CameraView { imageData in
                
                Task {
                    do {
                        let table = try await extractTable(from: imageData)
                        print("Tabela detectada:")
                        let parsed = parseTableGeneric(table)
                        prettyPrint(parsed)
                    } catch {
                        print("Erro: \(error)")
                    }
                }
            }
        }
    }
    
    /// Process an image and return the first table detected
    func extractTable(from image: Data) async throws -> DocumentObservation.Container.Table {
        
        // The Vision request.
        let request = RecognizeDocumentsRequest()
        
        // Perform the request on the image data and return the results.
        let observations = try await request.perform(on: image)

        // Get the first observation from the array.
        guard let document = observations.first?.document else {
            throw AppError.noDocument
        }
        
        // Extract the first table detected.
        guard let table = document.tables.first else {
            throw AppError.noTable
        }
        
        return table
    }
    
    /// Converte uma tabela do Vision em uma estrutura genérica
    func parseTableGeneric(_ table: DocumentObservation.Container.Table) -> ParsedTable {
        
        var rows: [[String]] = []
        
        // Itera sobre cada linha da tabela
        for row in table.rows {
            
            var parsedRow: [String] = []
            
            // Itera sobre cada célula da linha
            for cell in row {
                
                // Extrai o texto bruto da célula
                let text = cell.content.text.transcript
                
                // Limpa espaços/quebras de linha
                let cleaned = text
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                parsedRow.append(cleaned)
            }
            
            rows.append(parsedRow)
        }
        
        // Heurística simples: primeira linha como header
        let headers = rows.first
        let dataRows = Array(rows.dropFirst())
        
        return ParsedTable(headers: headers, rows: dataRows)
    }
    
    func prettyPrint(_ table: ParsedTable) {
        
        let allRows = [table.headers ?? []] + table.rows
        
        // Calcula largura máxima de cada coluna
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
        
        // Header
        if let headers = table.headers {
            print(formatRow(headers))
            
            // Linha separadora
            let separator = columnWidths.map { String(repeating: "-", count: $0) }
                .joined(separator: "-+-")
            print(separator)
        }
        
        // Linhas
        for row in table.rows {
            print(formatRow(row))
        }
    }
}

#Preview {
    ContentView()
}

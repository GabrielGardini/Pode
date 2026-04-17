//
//  ScanView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData
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

struct ScanView: View {
    @Query var children: [Child]
    @Environment(\.modelContext) var modelContext
    
    @State private var scannedText: String = ""
    @State private var presentScanner: Bool = false
    @State private var formattedTable: String = ""

    @State private var showFoodAnalysis: Bool = false
    @State private var analysisInput: String? = nil
    
    @State private var result: String? = nil

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(isActive: $showFoodAnalysis) {
                    FoodAnalysisView(json: result)
                } label: {
                    EmptyView()
                }
                .hidden()
                
                Text("Scaneie a tabela nutricional!")
                
                if !formattedTable.isEmpty {
                    ScrollView {
                        Text(formattedTable)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Scan")
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
                        let formatted = formatTable(parsed)
                        formattedTable = formatted
                        await handleScannedTable(parsed)
                        
                        await MainActor.run {
                            showFoodAnalysis = true
                        }
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
    
    func formatTable(_ table: ParsedTable) -> String {
        let allRows = [table.headers ?? []] + table.rows

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

        if let headers = table.headers {
            lines.append(formatRow(headers))
            let separator = columnWidths.map { String(repeating: "-", count: $0) }
                .joined(separator: "-+-")
            lines.append(separator)
        }

        for row in table.rows {
            lines.append(formatRow(row))
        }

        return lines.joined(separator: "\n")
    }
    
    /// Called after scanning when the full table is available. It can trigger further processing.
    func handleScannedTable(_ table: ParsedTable) async {
        do {
            // Fetch children from SwiftData database
            let descriptor = FetchDescriptor<Child>()
            let fetchedChildren = try modelContext.fetch(descriptor)
            
            self.result = await requisicao(description: "cheetos", table: formatTable(table), children: fetchedChildren)
            // Optionally retain input for next view if needed
            await MainActor.run {
                analysisInput = formatTable(table)
            }
            
        } catch {
            // Handle fetch errors appropriately (log or show UI as needed)
            print("Failed to fetch children: \(error)")
        }
    }

    
    func prettyPrint(_ table: ParsedTable) {
        let output = formatTable(table)
        print(output)
    }
}


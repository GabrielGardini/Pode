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
    
    @StateObject private var viewModel = FoodAnalysisViewModel(
        service: OpenAIService(apiKey: SecretManager.apiKey)
    )
    
    @State private var presentScanner = false
    @State private var formattedTable = ""
    @State private var showFoodAnalysis = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Escaneie a tabela nutricional!")

                if case .loading = viewModel.state {
                    ProgressView("Analisando...")
                }

                if case .failed(let error) = viewModel.state {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .onChange(of: viewModel.isLoaded) { oldValue, newValue in
                if newValue {
                    showFoodAnalysis = true
                }
            }
            .navigationDestination(isPresented: $showFoodAnalysis) {
                destinationView()
            }
            .navigationTitle("Scan")
            .toolbar {
                Button {
                    presentScanner = true
                } label: {
                    Label("Ler Tabela", systemImage: "camera.viewfinder")
                }
            }
        }
        .sheet(isPresented: $presentScanner) {
            CameraView { imageData in
                Task {
                    do {
                        showFoodAnalysis = false
                        
                        let table = try await extractTable(from: imageData)
                        let parsed = parseTableGeneric(table)
                        
                        formattedTable = formatTable(parsed)
                        
                        handleScannedTable(parsed)
                        
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func handleScannedTable(_ table: ParsedTable) {
        viewModel.analyze(
            description: "cookies",
            table: formatTable(table),
            children: children
        )
    }
    
    @ViewBuilder
    private func destinationView() -> some View {
        switch viewModel.state {
        case .loaded(let response):
            FoodAnalysisView(response: response)
        case .failed(let error):
            Text(error)
        default:
            ProgressView()
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
}


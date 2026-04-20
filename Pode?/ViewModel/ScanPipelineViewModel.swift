//
//  ScanPipelineViewModel.swift
//  Pode?
//
//  Created by Marlon Ribas on 20/04/26.
//

import SwiftUI
import Combine

enum AppError: Error {
    case invalidImage
    case network
    case api(String)
    case decoding
    case unknown
    
    var message: String {
        switch self {
        case .invalidImage:
            return "Imagem inválida."
        case .network:
            return "Erro de conexão."
        case .api(let msg):
            return msg
        case .decoding:
            return "Erro ao processar resposta."
        case .unknown:
            return "Erro inesperado."
        }
    }
}

@MainActor
final class ScanPipelineViewModel: ObservableObject {
    
    enum State {
        case idle
        case processing
        case success(FoodAnalysisResponse)
        case error(String)
    }
    
    @Published var state: State = .idle
    
    var isProcessing: Bool {
        if case .processing = state { return true }
        return false
    }
    
    private let tableService: TableExtractionService
    private let aiService: OpenAIService
    
    // MARK: - Init
    
    init(
        tableService: TableExtractionService = TableExtractionService(),
        aiService: OpenAIService
    ) {
        self.tableService = tableService
        self.aiService = aiService
    }
    
    // MARK: - Logging
    
    private func log(_ message: String) {
        print("📊 [ScanPipeline] \(message)")
    }
    
    // MARK: - Pipeline
    
    func process(result: ScanResult, children: [Child]) {
        guard !isProcessing else { return }
        
        log("Iniciando processamento")
        
        state = .processing
        
        Task {
            do {
                // 1. Validar imagem
                guard let image = result.image,
                      let data = image.jpegData(compressionQuality: 1.0)
                else {
                    log("Falha: imagem inválida")
                    throw AppError.invalidImage
                }
                
                log("Imagem válida")
                
                // 2. Extrair tabela
                let parsedTable = try await tableService
                    .extractAndParseTable(from: data)
                
                log("Tabela extraída")
                
                // 3. Montar prompt
                let formattedChildren = ChildFormatter.format(children)
                
                let prompt = PromptBuilder.build(
                    description: result.description,
                    table: parsedTable.formattedString,
                    children: formattedChildren
                )
                
                log("Prompt montado")
                
                // 4. Chamar IA
                let rawResponse = try await aiService.analyzeFood(prompt: prompt)
                
                log("Resposta da IA recebida")
                
                // 5. Decodificar resposta
                let decoded = try decodeAIResponse(rawResponse)
                
                log("Decoding realizado com sucesso")
                
                state = .success(decoded)
                
            } catch {
                let mapped = mapError(error)
                log("Erro: \(mapped)")
                state = .error(mapped)
            }
        }
    }
}

extension ScanPipelineViewModel {
    
    private func decodeAIResponse(_ text: String) throws -> FoodAnalysisResponse {
        
        guard let jsonData = extractJSON(from: text) else {
            log("Falha ao extrair JSON")
            throw AppError.decoding
        }
        
        do {
            return try JSONDecoder().decode(FoodAnalysisResponse.self, from: jsonData)
        } catch {
            log("Erro ao decodificar JSON")
            print("JSON bruto:\n\(text)")
            throw AppError.decoding
        }
    }
    
    private func extractJSON(from text: String) -> Data? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }
        
        let jsonString = text[start...end]
        return String(jsonString).data(using: .utf8)
    }
    
    private func mapError(_ error: Error) -> String {
        
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return "Erro interno (URL)"
            case .invalidResponse:
                return "Resposta inválida da API"
            case .decodingError:
                return "Erro ao interpretar resposta da IA"
            case .apiError(let message):
                return message
            case .network:
                return "Erro de conexão"
            }
        }
        
        if let appError = error as? AppError {
            return appError.message
        }
        
        return AppError.unknown.message
    }
}

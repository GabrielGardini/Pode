//import Foundation
//import Combine
//
//@MainActor
//final class FoodAnalysisViewModel: ObservableObject {
//    
//    enum State {
//        case idle
//        case loading
//        case loaded(FoodAnalysisResponse)
//        case failed(String)
//    }
//    
//    @Published var state: State = .idle
//    
//    var isLoaded: Bool {
//        if case .loaded = state {
//            return true
//        }
//        return false
//    }
//    
//    private let service: OpenAIService
//    
//    init(service: OpenAIService) {
//        self.service = service
//    }
//    
//    func analyze(
//        description: String,
//        table: String,
//        children: [Child]
//    ) {
//        print("Analisando a comida")
//        state = .loading
//        
//        Task {
//            do {
//                let formattedChildren = ChildFormatter.format(children)
//                
//                let prompt = PromptBuilder.build(
//                    description: description,
//                    table: table,
//                    children: formattedChildren
//                )
//                
//                let rawResponse = try await service.analyzeFood(prompt: prompt)
//                
//                let decoded = try decodeAIResponse(rawResponse)
//                
//                state = .loaded(decoded)
//                
//            } catch let error as APIError {
//                state = .failed(mapError(error))
//            } catch {
//                state = .failed("Erro inesperado")
//            }
//        }
//    }
//    
//    private func decodeAIResponse(_ text: String) throws -> FoodAnalysisResponse {
//        
//        guard let jsonData = extractJSON(from: text) else {
//            throw APIError.decodingError
//        }
//
//        do {
//            return try JSONDecoder().decode(FoodAnalysisResponse.self, from: jsonData)
//        } catch {
//            print("JSON bruto:\n\(text)")
//            throw APIError.decodingError
//        }
//    }
//    
//    private func extractJSON(from text: String) -> Data? {
//        guard let start = text.firstIndex(of: "{"),
//              let end = text.lastIndex(of: "}") else {
//            return nil
//        }
//
//        let jsonString = text[start...end]
//        return String(jsonString).data(using: .utf8)
//    }
//    
//    private func mapError(_ error: APIError) -> String {
//        switch error {
//        case .invalidURL:
//            return "Erro interno (URL)"
//        case .invalidResponse:
//            return "Resposta inválida da API"
//        case .decodingError:
//            return "Erro ao interpretar resposta da IA"
//        case .apiError(let message):
//            return message
//        case .network:
//            return "Erro de conexão"
//        }
//    }
//}

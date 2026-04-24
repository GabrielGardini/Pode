import Foundation
import SwiftUI

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case apiError(String)
    case network(Error)
}

struct OpenAIRequest: Codable {
    let model: String
    let input: String
}

struct OpenAIResponse: Codable {
    let output: [OutputItem]
}

struct OutputItem: Codable {
    let content: [ContentItem]
}

struct ContentItem: Codable {
    let text: String?
}

final class OpenAIService {
    
    private let session: URLSession
    private let apiKey: String
    
    init(session: URLSession = .shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }
    
    func analyzeFood(prompt: String) async throws -> String {
        guard let url = URL(string: "https://api.openai.com/v1/responses") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = OpenAIRequest(
            model: "gpt-5.4-mini",
            input: prompt
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8) ?? "Erro desconhecido"
                throw APIError.apiError(message)
            }
            
            let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let text = decoded.output.first?.content.first?.text else {
                throw APIError.invalidResponse
            }
            
            return text
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.network(error)
        }
    }
}

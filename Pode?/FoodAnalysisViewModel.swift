import Foundation
import Combine

final class FoodAnalysisViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(FoodAnalysisResponse)
        case failed(String)
    }

    @Published var state: State = .loading

    init(json: String) {
        decode(json: json)
    }

    private func decode(json: String) {
        guard let data = json.data(using: .utf8) else {
            state = .failed("O JSON informado não é válido em UTF-8.")
            return
        }

        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(FoodAnalysisResponse.self, from: data)
            state = .loaded(response)
        } catch {
            state = .failed("Erro ao decodificar JSON: \(error.localizedDescription)")
        }
    }
}


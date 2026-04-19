//
//  TableScannerViewModel.swift
//  Pode?
//
//  Created by Marlon Ribas on 19/04/26.
//


import SwiftUI
import Combine

@MainActor
final class TableScannerViewModel: ObservableObject {
    // Estados da View
    @Published var extractedText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    // Injeção de dependência do serviço
    private let service = TableExtractionService()
    
    @MainActor
    func processImage(_ data: Data) async {
        isLoading = true
        errorMessage = nil
        extractedText = ""
        
        do {
            let parsedTable = try await service.extractAndParseTable(from: data)
            self.extractedText = parsedTable.formattedString
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
        
        isLoading = false
    }
}

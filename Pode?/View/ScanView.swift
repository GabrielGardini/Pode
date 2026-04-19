//
//  ScanView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct ScanResult: Identifiable, Equatable {
    var id = UUID()
    var image: UIImage?
    var description: String
    
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        lhs.description == rhs.description &&
        lhs.image == rhs.image
    }
}

enum ScanFlowState {
    case idle
    case processing
    case success(FoodAnalysisResponse)
    case error(String)
}

struct ScanView: View {
    
    @Query var children: [Child]
    
    @State private var result = ScanResult(image: nil, description: "")
    @State private var presentScanner = false
    
    @State private var isProcessing = false
    @State private var flowState: ScanFlowState = .idle
    
    @StateObject private var tableScannerViewModel = TableScannerViewModel()
    @StateObject private var foodAnalysisViewModel = FoodAnalysisViewModel(
        service: OpenAIService(apiKey: SecretManager.apiKey)
    )
    
    // MARK: - Derived State
    
    private var isLoading: Bool {
        if case .processing = flowState { return true }
        return false
    }
    
    private var isShowingResult: Bool {
        if case .success = flowState { return true }
        return false
    }
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Processando...")
                }
                
                // 📸 PREVIEW DO RESULTADO
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // 📝 DESCRIÇÃO
                if !result.description.isEmpty {
                    Text(result.description)
                        .font(.headline)
                }
            }
            .navigationTitle("Scan")
            .toolbar {
                Button {
                    presentScanner = true
                } label: {
                    Label("Ler Tabela", systemImage: "camera.viewfinder")
                }
                .disabled(isProcessing)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { isShowingResult },
                    set: { if !$0 { flowState = .idle } }
                )
            ) {
                destinationView()
            }
        }
        .sheet(isPresented: $presentScanner) {
            ScannerFlowView(
                result: $result,
                onFinish: handleScannerFinish
            )
        }
        .alert(
            "Erro",
            isPresented: Binding(
                get: {
                    if case .error = flowState { return true }
                    return false
                },
                set: { _ in flowState = .idle }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            if case .error(let message) = flowState {
                Text(message)
            }
        }
    }
}

extension ScanView {
    
    // MARK: - Flow Entry
    
    func handleScannerFinish(_ final: ScanResult) {
        print("Processando o resultado")
        result = final
        presentScanner = false
        processFinalResult(final)
    }
    
    // MARK: - Pipeline
    
    func processFinalResult(_ final: ScanResult) {
        guard !isProcessing else { return }
        
        isProcessing = true
        flowState = .processing
        
        Task {
            defer { isProcessing = false }
            
            guard let uiImage = final.image,
                  let imageData = uiImage.jpegData(compressionQuality: 1.0)
            else {
                flowState = .error("Imagem inválida.")
                return
            }
            
            await tableScannerViewModel.processImage(imageData)
            
            if tableScannerViewModel.showError {
                flowState = .error(
                    tableScannerViewModel.errorMessage ?? "Erro ao extrair tabela."
                )
                return
            }
            
            foodAnalysisViewModel.analyze(description: result.description,
                                          table: tableScannerViewModel.extractedText,
                                          children: children)
        }
    }
}

extension ScanView {
    
    @ViewBuilder
    func destinationView() -> some View {
        if case .success(let response) = flowState {
            FoodAnalysisView(response: response)
        } else {
            ProgressView()
        }
    }
}

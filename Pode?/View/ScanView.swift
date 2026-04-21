//
//  ScanView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct ScanView: View {
    
    @Query var children: [Child]
    
    @State private var result = ScanResult(image: nil, description: "")
    @State private var presentScanner = false
    
    @StateObject private var pipeline = ScanPipelineViewModel(
        tableService: TableExtractionService(),
        aiService: OpenAIService(apiKey: SecretManager.apiKey)
    )
    
    private var isLoading: Bool {
        if case .processing = pipeline.state { return true }
        return false
    }
    
    private var isShowingResult: Bool {
        if case .success = pipeline.state { return true }
        return false
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // 🔄 LOADING
                if isLoading {
                    ProgressView("Processando...")
                }
                
                // 📸 PREVIEW
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
            .padding()
            .navigationTitle("Scan")
            .toolbar {
                Button {
                    presentScanner = true
                } label: {
                    Label("Ler Tabela", systemImage: "camera.viewfinder")
                }
                .disabled(isLoading)
            }
            
            // Navegação
            .navigationDestination(
                isPresented: Binding(
                    get: { isShowingResult },
                    set: { if !$0 { pipeline.state = .idle } }
                )
            ) {
                destinationView()
            }
        }
        
        // Scanner
        .sheet(isPresented: $presentScanner) {
            ScannerFlowView(
                result: $result,
                onFinish: handleScannerFinish
            )
            .presentationDetents([.large])
        }
        
        // Erros
        .alert(
            "Erro",
            isPresented: Binding(
                get: {
                    if case .error = pipeline.state { return true }
                    return false
                },
                set: { _ in pipeline.state = .idle }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            if case .error(let message) = pipeline.state {
                Text(message)
            }
        }
    }
}

// Actions
extension ScanView {
    
    func handleScannerFinish(_ final: ScanResult) {
        result = final
        presentScanner = false
        
        pipeline.process(
            result: final,
            children: children
        )
    }
}

// Navigation Destination
extension ScanView {
    
    @ViewBuilder
    func destinationView() -> some View {
        switch pipeline.state {
            
        case .success(let response):
            FoodAnalysisView(response: response)
            
        case .processing:
            ProgressView()
            
        default:
            EmptyView()
        }
    }
}

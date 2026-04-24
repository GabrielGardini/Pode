//
//  ScanView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct ScanView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @Query var children: [Child]
    
    @State private var result = ScanResult(image: nil, description: "")
    @State private var presentScanner = false
    @State private var showOnboarding = false
    
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
            ZStack(alignment: .center) {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                            .padding()
                        tipsSection
                            .padding()
                        bottomCTA
                    }
                }
                .navigationTitle("Escanear")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(
                    isPresented: Binding(
                        get: { isShowingResult },
                        set: { if !$0 { pipeline.state = .idle } }
                    )
                ) {
                    destinationView()
                }
                
                if isLoading {
                    loadingOverlay
                }
            }
        }
        .sheet(isPresented: $presentScanner) {
            ScannerFlowView(
                result: $result,
                onFinish: handleScannerFinish
            )
        }
        .alert(
            "Não foi possível concluir a leitura",
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
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
                .interactiveDismissDisabled(true)
        }
    }
}

// MARK: - Sections
private extension ScanView {
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Fotografe a tabela nutricional ou a lista de ingredientes para verificar se o alimento é adequado para a criança.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
        
    var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Para um resultado melhor")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                tipItem("Limpe as lentes da câmera.")
                tipItem("Use boa iluminação e evite sombras.")
                tipItem("Centralize a tabela.")
                tipItem("Mantenha o celular firme por alguns segundos.")
            }
        }
    }
    
    var bottomCTA: some View {
        VStack(spacing: 0) {
            Button {
                presentScanner = true
            } label: {
                Label("Escanear alimento", systemImage: "camera.viewfinder")
                    .padding(8)
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .disabled(isLoading || children.isEmpty)
            .accessibilityHint(children.isEmpty ? "Adicione uma criança para escanear alimentos." : "")
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            if children.isEmpty {
                Text("Adicione uma criança para escanear alimentos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                ProgressView()
                    .controlSize(.large)
                    .tint(.accentColor)
                
                VStack(spacing: 4) {
                    Text("Analisando informações…")
                        .font(.headline)
                    
                    Text("Isso leva apenas alguns segundos")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        }
        .transition(.opacity)
    }
    
    func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(Color.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    func tipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Actions
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

// MARK: - Navigation Destination
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


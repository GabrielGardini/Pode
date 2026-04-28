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
    @State private var showHowItWorks = false
    @State private var appear = false
    
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
                    VStack {
                        heroSection
                        tipsCard
                        bottomCTA
                    }
                }
                .navigationTitle("Scan")
                .navigationBarTitleDisplayMode(.large)
                .background(
                    MeshGradient(width: 3,
                                 height: 3,
                                 points: [
                                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                                    [0.0, 0.5], appear ? [0.5, 0.5] : [0.8, 0.2], [1.0, 0.5],
                                    [0.0, 1.0], [appear ? 0.5 : 1.0, 1.0], [1.0, 1.0],
                                 ], colors: [
                                    appear ? .teal.opacity(0.2) : .teal.opacity(0.2), Color.accentColor.opacity(0.2), .blue.opacity(0.05),
                                    Color.accentColor.opacity(0.3), .teal.opacity(0.1), Color.accentColor.opacity(0.2),
                                    Color.accentColor.opacity(0.05), .teal.opacity(0.05), appear ? .teal.opacity(0.3) : Color.accentColor.opacity(0.05)
                                 ])
                    .ignoresSafeArea()
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showHowItWorks = true
                        } label: {
                            Label("Como funciona", systemImage: "info.circle")
                        }
                    }
                }
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
        .sheet(isPresented: $showHowItWorks) {
            HowItWorksView()
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
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                appear.toggle()
            }
        }
    }
}

// MARK: - Sections
private extension ScanView {
    
    var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 96, height: 96)
                
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.top, 8)
            
            VStack(spacing: 6) {
                Text("Verifique o alimento")
                    .font(.title2.weight(.semibold))
                
                Text("Fotografe a tabela nutricional para saber se o alimento é adequado para a criança.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var tipsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.accentColor)
                    .font(.headline)
                Text("Para um resultado melhor")
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .padding(.leading, 16)
            
            VStack(spacing: 0) {
                tipRow(
                    icon: "camera.aperture",
                    text: "Limpe as lentes da câmera"
                )
                Divider().padding(.leading, 52)
                tipRow(
                    icon: "sun.max",
                    text: "Use boa iluminação e evite sombras"
                )
                Divider().padding(.leading, 52)
                tipRow(
                    icon: "viewfinder",
                    text: "Centralize a tabela no enquadramento"
                )
                Divider().padding(.leading, 52)
                tipRow(
                    icon: "hand.raised",
                    text: "Mantenha o celular firme por alguns segundos"
                )
            }
            .padding(.bottom)
        }
//        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
            
            if children.isEmpty {
                Text("Adicione uma criança para escanear alimentos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }
    
    var loadingOverlay: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.01) // blocks interaction
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
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
    }
    
    func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, alignment: .center)
 
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
 
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
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


import SwiftUI
import SwiftData

struct OnboardingStep: Identifiable, Hashable {
    let id = UUID()
    let title: String?
    let subtitle: String?
    let systemImage: String?
}

struct OnboardingView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var currentIndex: Int = 0
    
    @State private var name: String = ""
    @State private var birthDate: Date = .now

    @State private var viewModel: ChildViewModel = ChildViewModel()
    
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Bem-vindo ao Pode Comer?",
            subtitle: "Descubra rapidamente se um alimento é adequado para a criança.",
            systemImage: "sparkles"
        ),
        OnboardingStep(
            title: "Escaneie tabelas nutricionais",
            subtitle: "Use a câmera para capturar a tabela nutricional.",
            systemImage: "camera.viewfinder"
        ),
        OnboardingStep(
            title: "Entenda o resultado",
            subtitle: "Cada alimento recebe uma pontuação e uma orientação personalizada para cada criança.",
            systemImage: "checkmark.shield"
        ),
        OnboardingStep(
            title: "Comece adicionando uma criança",
            subtitle: nil,
            systemImage: nil
        )
    ]
    
    private var isLastStep: Bool { currentIndex == steps.count - 1 }
    
    private var isFutureDate: Bool { birthDate > .now }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentIndex) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    stepContent(for: index, step: step)
                        .tag(index)
                        .padding(.horizontal, 24)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .tint(.accentColor)
            .onAppear {
                let current = UIColor(Color.accentColor)
                UIPageControl.appearance().currentPageIndicatorTintColor = current
                UIPageControl.appearance().pageIndicatorTintColor = current.withAlphaComponent(0.3)
            }
            .onChange(of: currentIndex) { _, index in
                let isLast = index == steps.count - 1
                UIPageControl.appearance().alpha = isLast ? 0 : 1
            }
            
            bottomBar
        }
    }
    
    @ViewBuilder
    private func stepContent(for index: Int, step: OnboardingStep) -> some View {
        switch index {
        case 1:
            ScanAnimationStepView(step: step, isActive: currentIndex == 1)
        case 2:
            ResultStepView(step: step, isActive: currentIndex == 2)
        case 3:
            AddChildOnboardingView(step: step, isActive: currentIndex == 3, name: $name, birthDate: $birthDate)
        default:
            DefaultStepView(step: step, isActive: currentIndex == index)
        }
    }
    
    //    private var bottomBar: some View {
    //        VStack(spacing: 12) {
    //            Button {
    //                if isLastStep {
    //                    finishOnboarding()
    //                } else {
    //                    withAnimation(.spring(duration: 0.4)) { currentIndex += 1 }
    //                }
    //            } label: {
    //                Text(isLastStep ? "Começar" : "Próximo")
    //                    .padding(8)
    //            }
    //            .buttonStyle(.glassProminent)
    //            .buttonSizing(.flexible)
    //            .padding(.horizontal, 16)
    //            .padding(.bottom, 8)
    //
    //            if !isLastStep {
    //                Button {
    //                    finishOnboarding()
    //                } label: {
    //                    Text("Pular")
    //                        .foregroundStyle(.secondary)
    //                        .padding(8)
    //                }
    //                .buttonStyle(.plain)
    //                .buttonSizing(.flexible)
    //            }
    //        }
    //        .padding(.bottom, 32)
    //        .padding(.top, 8)
    //    }
    @ViewBuilder
    private var bottomBar: some View {
        
        // último step
        if currentIndex == 3 {
            
            Button(role: .confirm) {
                viewModel.addChild(
                    name: name,
                    birthDate: birthDate,
                    context: modelContext
                )
                
                finishOnboarding()
            } label: {
                Text("Continuar")
                    .padding(8)
            }
            .disabled(name.isEmpty || isFutureDate)
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
        } else {
            
            VStack(spacing: 12) {
                
                Button {
                    withAnimation(.spring(duration: 0.4)) {
                        currentIndex += 1
                    }
                } label: {
                    Text("Próximo")
                        .padding(8)
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                Button {
                    finishOnboarding()
                } label: {
                    Text("Pular")
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .buttonSizing(.flexible)
            }
            .padding(.bottom, 32)
            .padding(.top, 8)
        }
    }
    
    private func finishOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
}

#Preview {
    OnboardingView()
}

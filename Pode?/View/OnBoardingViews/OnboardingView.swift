import SwiftUI

struct OnboardingStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

struct OnboardingView: View {
 
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
 
    @State private var currentIndex: Int = 0
 
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Bem-vindo ao Pode?",
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
        )
    ]
 
    private var isLastStep: Bool { currentIndex == steps.count - 1 }
 
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
        default:
            DefaultStepView(step: step, isActive: currentIndex == index)
        }
    }
 
    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button {
                if isLastStep {
                    finishOnboarding()
                } else {
                    withAnimation(.spring(duration: 0.4)) { currentIndex += 1 }
                }
            } label: {
                Text(isLastStep ? "Começar" : "Próximo")
                    .padding(8)
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
 
            if !isLastStep {
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
        }
        .padding(.bottom, 32)
        .padding(.top, 8)
    }
 
    private func finishOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
}

#Preview {
    OnboardingView()
}

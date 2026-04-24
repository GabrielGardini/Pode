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
            title: "Escaneie rótulos",
            subtitle: "Use a câmera para capturar a tabela nutricional.",
            systemImage: "camera.viewfinder"
        ),
        OnboardingStep(
            title: "Receba orientações",
            subtitle: "Veja insights claros e recomendações personalizadas.",
            systemImage: "checkmark.shield"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentIndex) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    stepView(step)
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

    private var isLastStep: Bool { currentIndex == steps.count - 1 }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            
            Button {
                if isLastStep {
                    finishOnboarding()
                } else {
                    withAnimation { currentIndex += 1 }
                }
            } label: {
                Text(isLastStep ? "Começar" : "Próximo")
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
                    .padding(8)
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .tint(.gray)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func finishOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }

    private func stepView(_ step: OnboardingStep) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            Image(systemName: step.systemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .padding(8)

            Text(step.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text(step.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer(minLength: 20)
        }
    }
}

#Preview {
    OnboardingView()
}

//import SwiftUI
//
//struct OnboardingStep: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let subtitle: String
//    let systemImage: String
//}
//
//struct OnboardingView: View {
//    @Environment(\.dismiss) private var dismiss
//    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
//
//    @State private var currentIndex: Int = 0
//
//    private let steps: [OnboardingStep] = [
//        OnboardingStep(
//            title: "Bem-vindo ao Pode?",
//            subtitle: "Descubra rapidamente se um alimento é adequado para a criança.",
//            systemImage: "sparkles"
//        ),
//        OnboardingStep(
//            title: "Escaneie rótulos",
//            subtitle: "Use a câmera para capturar a tabela nutricional.",
//            systemImage: "camera.viewfinder"
//        ),
//        OnboardingStep(
//            title: "Receba orientações",
//            subtitle: "Veja insights claros e recomendações personalizadas.",
//            systemImage: "checkmark.shield"
//        )
//    ]
//
//    var body: some View {
//        VStack(spacing: 0) {
//            TabView(selection: $currentIndex) {
//                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
//                    stepView(step)
//                        .tag(index)
//                        .padding(.horizontal, 24)
//                }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .always))
//            .tint(.accentColor)
//            .onAppear {
//                let current = UIColor(Color.accentColor)
//                UIPageControl.appearance().currentPageIndicatorTintColor = current
//                UIPageControl.appearance().pageIndicatorTintColor = current.withAlphaComponent(0.3)
//            }
//
//            bottomBar
//        }
//    }
//
//    private var isLastStep: Bool { currentIndex == steps.count - 1 }
//
//    private var bottomBar: some View {
//        VStack(spacing: 12) {
//
//            Button {
//                if isLastStep {
//                    finishOnboarding()
//                } else {
//                    withAnimation { currentIndex += 1 }
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
//            Button {
//                finishOnboarding()
//            } label: {
//                Text("Pular")
//                    .padding(8)
//            }
//            .buttonStyle(.glassProminent)
//            .buttonSizing(.flexible)
//            .tint(.gray)
//            .padding(.horizontal, 16)
//            .padding(.bottom, 8)
//        }
//    }
//
//    private func finishOnboarding() {
//        hasCompletedOnboarding = true
//        dismiss()
//    }
//
//    private func stepView(_ step: OnboardingStep) -> some View {
//        VStack(spacing: 20) {
//            Spacer(minLength: 20)
//
//            Image(systemName: step.systemImage)
//                .symbolRenderingMode(.hierarchical)
//                .font(.system(size: 72, weight: .regular))
//                .foregroundStyle(Color.accentColor)
//                .padding(8)
//
//            Text(step.title)
//                .font(.largeTitle.bold())
//                .multilineTextAlignment(.center)
//                .foregroundStyle(.primary)
//
//            Text(step.subtitle)
//                .font(.body)
//                .multilineTextAlignment(.center)
//                .foregroundStyle(.secondary)
//                .padding(.horizontal)
//
//            Spacer(minLength: 20)
//        }
//    }
//}

import SwiftUI

// MARK: - Model
struct OnboardingStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

// MARK: - Main View

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
    
    // MARK: - Step routing
    
    @ViewBuilder
    private func stepContent(for index: Int, step: OnboardingStep) -> some View {
        switch index {
        case 1:
            ScanAnimationStepView(step: step)
        case 2:
            ResultStepView(step: step)
        default:
            DefaultStepView(step: step)
        }
    }
    
    // MARK: - Bottom bar
    
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

// MARK: - Step 1: Default

struct DefaultStepView: View {
    let step: OnboardingStep
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)
            
            Image(systemName: step.systemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(duration: 0.6, bounce: 0.4), value: appeared)
            
            VStack(spacing: 10) {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.15), value: appeared)
                
                Text(step.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(0.25), value: appeared)
            }
            
            Spacer(minLength: 20)
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}

// MARK: - Step 2: Scan Animation

struct ScanAnimationStepView: View {
    let step: OnboardingStep
    
    @State private var appeared = false
    @State private var scanOffset: CGFloat = -80
    @State private var scanOpacity: Double = 0
    @State private var cornerPulse = false
    @State private var dotsVisible = false
    
    private let frameSize: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)
            
            // Scan frame
            ZStack {
                // Simulated label content
                VStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemFill))
                            .frame(width: CGFloat.random(in: 80...140), height: 8)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeIn(duration: 0.2).delay(0.3 + Double(i) * 0.07), value: appeared)
                    }
                }
                
                // Scan line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0), Color.accentColor, Color.accentColor.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .offset(y: scanOffset)
                    .opacity(scanOpacity)
                
                // Corner marks
                ScanCorners(pulse: cornerPulse)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: frameSize, height: frameSize)
            }
            .frame(width: frameSize, height: frameSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 10) {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.15), value: appeared)
                
                Text(step.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(0.25), value: appeared)
            }
            
            Spacer(minLength: 20)
        }
        .onAppear {
            appeared = true
            dotsVisible = true
            startScanAnimation()
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                cornerPulse = true
            }
        }
        .onDisappear {
            appeared = false
            dotsVisible = false
        }
    }
    
    private func startScanAnimation() {
        scanOffset = -80
        withAnimation(.easeIn(duration: 0.3)) {
            scanOpacity = 1
        }
        withAnimation(.easeInOut(duration: 1.4).delay(0.1).repeatForever(autoreverses: false)) {
            scanOffset = 80
        }
    }
}

// Scan corner brackets
struct ScanCorners: View {
    var pulse: Bool
    private let length: CGFloat = 24
    private let thickness: CGFloat = 3
    private let radius: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Top-left
            cornerMark(rotation: 0)
                .position(x: length / 2, y: length / 2)
            // Top-right
            cornerMark(rotation: 90)
                .position(x: 200 - length / 2, y: length / 2)
            // Bottom-left
            cornerMark(rotation: 270)
                .position(x: length / 2, y: 200 - length / 2)
            // Bottom-right
            cornerMark(rotation: 180)
                .position(x: 200 - length / 2, y: 200 - length / 2)
        }
        .scaleEffect(pulse ? 1.04 : 1.0)
    }
    
    private func cornerMark(rotation: Double) -> some View {
        CornerShape(length: length, thickness: thickness)
            .rotationEffect(.degrees(rotation))
    }
}

struct CornerShape: Shape {
    let length: CGFloat
    let thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: length))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: length, y: 0))
        return path.strokedPath(.init(lineWidth: thickness, lineCap: .round))
    }
}

struct ProcessingDots: View {
    let visible: Bool
    @State private var phase = 0
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundStyle(Color.accentColor)
                    .opacity(phase == i ? 1 : 0.3)
            }
        }
        .onAppear {
            guard visible else { return }
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Step 3: Result / Score

struct ResultStepView: View {
    let step: OnboardingStep
    
    @State private var appeared = false
    @State private var scoreValue: Int = 0
    @State private var badgesVisible = [false, false, false]
    
    private let demoScore: Int = 72
    
    private let badges: [(label: String, icon: String, color: Color, detail: String)] = [
        ("Pode", "checkmark.circle.fill", .green, "Adequado para a criança"),
        ("Evitável", "exclamationmark.triangle.fill", .orange, "Consumo com moderação"),
        ("Não pode", "xmark.octagon.fill", .red, "Não recomendado para a idade")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)
            
            // Score
            FoodScoreView(score: scoreValue)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)
                .animation(.spring(duration: 0.5), value: appeared)
            
            // Badges
            VStack(spacing: 10) {
                ForEach(Array(badges.enumerated()), id: \.offset) { i, badge in
                    HStack(spacing: 14) {
                        Image(systemName: badge.icon)
                            .font(.title3)
                            .foregroundStyle(badge.color)
                            .frame(width: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(badge.label)
                                .font(.subheadline.weight(.semibold))
                            Text(badge.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Mock child chip
                        Text("Ana, 2 anos")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(badge.color.opacity(0.12))
                            .foregroundStyle(badge.color)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .opacity(badgesVisible[i] ? 1 : 0)
                    .offset(x: badgesVisible[i] ? 0 : 32)
                    .animation(.spring(duration: 0.5, bounce: 0.3).delay(0.5 + Double(i) * 0.15), value: badgesVisible[i])
                }
            }
            
            VStack(spacing: 10) {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.15), value: appeared)
                
                Text(step.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(0.25), value: appeared)
            }
            
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 4)
        .onAppear {
            print(scoreValue)
            appeared = true
            scoreValue = 0
            
            withAnimation(.easeOut(duration: 0.6)) {
                scoreValue = demoScore
            }
            
            for i in badges.indices {
                badgesVisible[i] = true
            }
        }
        .onDisappear {
            print(scoreValue)
            appeared = false
            badgesVisible = [false, false, false]
        }
    }
}

#Preview {
    OnboardingView()
}


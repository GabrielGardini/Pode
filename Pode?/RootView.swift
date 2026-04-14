import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var criancas: [Crianca]
    @State private var showOnboarding: Bool = true

    init() {
        // default; real value will be set in body via onAppear
        _criancas = Query(FetchDescriptor<Crianca>())
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingCriancasView {
                    showOnboarding = false
                }
            } else {
                MainContentView()
            }
        }
        .onAppear {
            showOnboarding = criancas.isEmpty
        }
    }
}

// Placeholder for main content; replace with your real home view.
struct MainContentView: View {
    var body: some View {
        NavigationStack {
            Text("Tela principal")
                .navigationTitle("Pode?")
        }
    }
}

//#Preview {
//    ModelPreview { RootView() }
//}

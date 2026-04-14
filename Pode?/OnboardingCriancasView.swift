import SwiftUI
import SwiftData

struct OnboardingCriancasView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Crianca.createdAt) private var criancas: [Crianca]

    @State private var isAddingChild = false
    
    var onFinished: (() -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if criancas.isEmpty {
                    Text("Vamos começar adicionando uma criança.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    List(criancas) { c in
                        VStack(alignment: .leading) {
                            Text(c.nome).font(.headline)
                            HStack {
                                Text("Idade: \(c.idade)")
                                if !c.info.isEmpty {
                                    Text("• \(c.info)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            Text(c.dataNascimento, style: .date)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                Button("Adicionar criança") {
                    isAddingChild = true
                }
                .buttonStyle(.borderedProminent)

                if !criancas.isEmpty {
                    Button("Ir para a tela principal") {
                        onFinished?()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer(minLength: 8)
            }
            .padding()
            .navigationTitle("Bem-vindo")
            .sheet(isPresented: $isAddingChild) {
                CadastroCriancaView(onSaved: {
                    isAddingChild = false
                })
            }
        }
    }
}

#Preview {
    OnboardingCriancasView()
}

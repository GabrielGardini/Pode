//
//  HowItWorksView.swift
//  Pode?
//
//  Created by Marlon Ribas on 27/04/26.
//


import SwiftUI

struct HowItWorksView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 32, weight: .light))
                                .foregroundStyle(Color.accentColor)
                        }

                        VStack(spacing: 6) {
                            Text("Como a IA interpreta")
                                .font(.title3.weight(.semibold))
                            Text("Entenda como analisamos as informações do alimento para oferecer uma resposta confiável.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                // MARK: - O que a câmera captura
                Section {
                    infoRow(
                        icon: "camera.fill",
                        iconColor: .accentColor,
                        title: "Captura da imagem",
                        description: "O app fotografa a tabela nutricional ou a lista de ingredientes. Quanto mais nítida e bem iluminada, mais precisa será a leitura."
                    )
                    infoRow(
                        icon: "doc.text.viewfinder",
                        iconColor: .accentColor,
                        title: "Extração do texto",
                        description: "Um motor de OCR (reconhecimento óptico de caracteres) converte o que está escrito na imagem em texto legível para a IA."
                    )
                } header: {
                    sectionHeader(icon: "camera.viewfinder", title: "Etapa 1 — Leitura")
                }

                // MARK: - Como a IA analisa
                Section {
                    infoRow(
                        icon: "list.bullet.rectangle",
                        iconColor: .accentColor,
                        title: "Tabela nutricional",
                        description: "A IA identifica nutrientes como sódio, açúcares, gorduras saturadas e trans, e os compara com os limites recomendados para a faixa etária da criança."
                    )
                    infoRow(
                        icon: "text.alignleft",
                        iconColor: .accentColor,
                        title: "Lista de ingredientes",
                        description: "Cada ingrediente é avaliado individualmente. A IA detecta aditivos, conservantes, corantes e substâncias que podem ser prejudiciais ou inadequadas para crianças."
                    )
                    infoRow(
                        icon: "person.2",
                        iconColor: .accentColor,
                        title: "Perfil da criança",
                        description: "A análise leva em conta a idade cadastrada. Os limites nutricionais variam entre bebês, crianças pequenas e crianças em idade escolar."
                    )
                } header: {
                    sectionHeader(icon: "cpu", title: "Etapa 2 — Análise")
                }

                // MARK: - Resultado
                Section {
                    infoRow(
                        icon: "checkmark.seal.fill",
                        iconColor: .green,
                        title: "Adequado",
                        description: "O alimento não apresenta ingredientes ou níveis nutricionais preocupantes para a faixa etária."
                    )
                    infoRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange,
                        title: "Atenção",
                        description: "Alguns itens merecem moderação — como excesso de açúcar ou sódio — mas não representam risco imediato."
                    )
                    infoRow(
                        icon: "xmark.octagon.fill",
                        iconColor: .red,
                        title: "Não recomendado",
                        description: "Foram encontrados ingredientes ou níveis nutricionais inadequados para a idade. É recomendável evitar o consumo."
                    )
                } header: {
                    sectionHeader(icon: "checkmark.shield", title: "Etapa 3 — Resultado")
                }

                // MARK: - Limitações
                Section {
                    infoRow(
                        icon: "exclamationmark.circle",
                        iconColor: .accentColor,
                        title: "Não substitui o pediatra",
                        description: "A análise é uma orientação informativa baseada em diretrizes gerais. Decisões sobre a alimentação da criança devem envolver um profissional de saúde."
                    )
                    infoRow(
                        icon: "photo.badge.exclamationmark",
                        iconColor: .accentColor,
                        title: "Qualidade da imagem importa",
                        description: "Fotos borradas, com reflexo ou mal enquadradas podem reduzir a precisão da leitura. Refaça o escaneamento se o resultado parecer incompleto."
                    )
                    infoRow(
                        icon: "globe",
                        iconColor: .accentColor,
                        title: "Rótulos parciais",
                        description: "Alimentos sem tabela nutricional completa ou com texto ilegível podem gerar análises inconclusivas. Sempre prefira rótulos completos e em bom estado."
                    )
                } header: {
                    sectionHeader(icon: "info.circle", title: "Limitações importantes")
                } footer: {
                    Text("Esta ferramenta usa inteligência artificial e pode cometer erros. Sempre consulte um pediatra ou nutricionista para orientações personalizadas.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Como funciona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension HowItWorksView {

    func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            Text(title)
        }
    }

    func infoRow(
        icon: String,
        iconColor: Color,
        title: String,
        description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 28, alignment: .center)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HowItWorksView()
}

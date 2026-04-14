import SwiftUI
import SwiftData

struct CadastroCriancaView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var nome: String = ""
    @State private var dataNascimento: Date = Date()
    @State private var observacoes: String = ""

    var onSaved: (() -> Void)?

    private var nomeValido: Bool {
        !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        campoTitulo("Nome do bebê")
                        textFieldBox {
                            TextField("Bebê", text: $nome)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .font(.system(size: 24, weight: .regular))
                        }

                        campoTitulo("Data de nascimento")
                        dateField

                        campoTitulo("Observações")
                        observacoesField
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }

                Button(action: salvar) {
                    Text("Salvar")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 68)
                        .background(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .fill(Color(red: 0.94, green: 0.45, blue: 0.53))
                        )
                }
                .disabled(!nomeValido)
                .opacity(nomeValido ? 1 : 0.6)
                .padding(.horizontal, 32)
                .padding(.bottom, 28)
                .padding(.top, 12)
                .background(Color(.systemBackground))
            }
            .background(Color(.systemGray6))
            .navigationTitle("Detalhes do bebê")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(.black)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        limparCampos()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(Color.red)
                    }
                }
            }
        }
    }

    private func campoTitulo(_ texto: String) -> some View {
        Text(texto)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(.gray)
    }

    private func textFieldBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 24)
            .frame(height: 104)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.gray.opacity(0.7), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.clear)
                    )
            )
    }

    private var dateField: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.gray.opacity(0.7), lineWidth: 2)
                .frame(height: 104)

            DatePicker(
                "",
                selection: $dataNascimento,
                in: ...Date.now,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .padding(.horizontal, 24)
            .scaleEffect(1.35, anchor: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var observacoesField: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.gray.opacity(0.7), lineWidth: 2)
                .frame(minHeight: 140)

            TextField("Escreva observações", text: $observacoes, axis: .vertical)
                .font(.system(size: 22, weight: .regular))
                .lineLimit(5, reservesSpace: true)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
        }
    }

    private func salvar() {
        let crianca = Crianca(
            nome: nome.trimmingCharacters(in: .whitespacesAndNewlines),
            dataNascimento: dataNascimento,
            info: observacoes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        context.insert(crianca)

        do {
            try context.save()
            onSaved?()
            dismiss()
        } catch {
            print("Erro ao salvar: \(error)")
        }
    }

    private func limparCampos() {
        nome = ""
        dataNascimento = Date()
        observacoes = ""
    }
}

#Preview {
    CadastroCriancaView()
}

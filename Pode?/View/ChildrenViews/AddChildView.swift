//
//  AddChildView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct AddChildView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var viewModel: ChildViewModel
    
    @State private var name: String = ""
    @State private var birthDate: Date = .now
    @State private var allergies: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nome")) {
                    TextField("", text: $name)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Data de nascimento")) {
                    DatePicker(
                        "",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                
                Section(header: Text("Restrições alimentares")) {
                    DisclosureGroup {
                        row("Amendoim")
                        row("Nozes")
                        row("Leite")
                        row("Ovos")
                        row("Soja")
                        row("Trigo")
                        row("Peixes")
                        row("Crustáceos")
                        row("Gergelim")
                    } label: {
                        Label {
                            Text("Alergias alimentares")
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                    }
                    
                    DisclosureGroup {
                        row("Lactose")
                        row("Glúten")
                        row("Frutose")
                    } label: {
                        Label {
                            Text("Intolerâncias alimentares")
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "drop.triangle")
                        }
                    }
                    
                    DisclosureGroup {
                        row("Doença celíaca")
                    } label: {
                        Label {
                            Text("Condições médicas")
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "cross.case")
                        }
                    }
                }
            }
            .navigationTitle("Adicionar criança")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        viewModel.addChild(name: name, birthDate: birthDate, allergies: allergies, context: modelContext)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    func row(_ item: String) -> some View {
        Button {
            if allergies.contains(item) {
                allergies.removeAll { $0 == item }
            } else {
                allergies.append(item)
            }
        } label: {
            HStack {
                Text(item)
                
                Spacer()
                
                Image(systemName: allergies.contains(item) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(allergies.contains(item) ? .accentColor : .gray)
            }
        }
        .buttonStyle(.plain)
    }
}

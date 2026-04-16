//
//  EditChildView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct EditChildView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    let child: Child
    var viewModel: ChildViewModel
    
    @State private var newName: String = ""
    @State private var newBirthDate: Date = .now
    @State private var newAllergies: [String] = []
    
    // INIT para pré-preencher os dados
    init(child: Child, viewModel: ChildViewModel) {
        self.child = child
        self.viewModel = viewModel
        
        _newName = State(initialValue: child.name)
        _newBirthDate = State(initialValue: child.birthDate)
        _newAllergies = State(initialValue: child.allergies)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nome")) {
                    TextField("\(child.name)", text: $newName)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Data de nascimento")) {
                    DatePicker(
                        "",
                        selection: $newBirthDate,
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
            .navigationTitle("Editar criança")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        viewModel.editChild(
                                child,
                                name: newName,
                                birthDate: newBirthDate,
                                allergies: newAllergies
                            )
                        dismiss()
                    }
                }
            }
        }
    }
    
    func row(_ item: String) -> some View {
        Button {
            toggle(item)
        } label: {
            HStack {
                Text(item)
                
                Spacer()
                
                Image(systemName: newAllergies.contains(item) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(newAllergies.contains(item) ? .accentColor : .gray)
            }
        }
        .buttonStyle(.plain)
    }
    
    func toggle(_ item: String) {
        if newAllergies.contains(item) {
            newAllergies.removeAll { $0 == item }
        } else {
            newAllergies.append(item)
        }
    }
    
    func isSelected(_ item: String) -> Bool {
        newAllergies.contains(item)
    }
}

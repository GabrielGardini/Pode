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
    
    // INIT para pré-preencher os dados
    init(child: Child, viewModel: ChildViewModel) {
        self.child = child
        self.viewModel = viewModel
        
        _newName = State(initialValue: child.name)
        _newBirthDate = State(initialValue: child.birthDate)
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
                                birthDate: newBirthDate
                            )
                        dismiss()
                    }
                }
            }
        }
    }
}

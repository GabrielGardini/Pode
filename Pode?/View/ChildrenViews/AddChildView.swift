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
                        viewModel.addChild(name: name, birthDate: birthDate, context: modelContext)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

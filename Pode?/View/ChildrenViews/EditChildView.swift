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
    
    private var age: String {
        let components = Calendar.current.dateComponents([.year, .month], from: newBirthDate, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0

        if newBirthDate > .now {
            return "Data inválida"
        } else if years == 0 && months == 0 {
            return "Recém-nascido"
        } else if years == 0 {
            return "\(months) \(months == 1 ? "mês" : "meses")"
        } else if months == 0 {
            return "\(years) \(years == 1 ? "ano" : "anos")"
        } else {
            return "\(years) \(years == 1 ? "ano" : "anos") e \(months) \(months == 1 ? "mês" : "meses")"
        }
    }
    
    private var isFutureDate: Bool {
        newBirthDate > .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Avatar preview
                Section {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: newName.isEmpty ? "person.fill" : "person.fill.checkmark")
                                .font(.system(size: 30, weight: .light))
                                .foregroundStyle(Color.accentColor)
                                .contentTransition(.symbolEffect(.replace))
                        }

                        if !newName.isEmpty {
                            Text(newName)
                                .font(.title3.weight(.semibold))
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else {
                            Text("Nova criança")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.spring(duration: 0.3), value: newName.isEmpty)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                // MARK: - Nome
                Section(header: Text("Nome")) {
                    TextField("Nome da criança", text: $newName)
                        .textInputAutocapitalization(.words)
                }

                // MARK: - Data de nascimento
                Section(header: Text("Data de nascimento")) {
                    DatePicker(
                        "",
                        selection: $newBirthDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)

                    if !isFutureDate {
                        HStack(spacing: 8) {
                            Image(systemName: "birthday.cake")
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 24)
                            Text(age)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .animation(.spring(duration: 0.3), value: age)
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
                                birthDate: newBirthDate
                            )
                        dismiss()
                    }
                }
            }
        }
    }
}

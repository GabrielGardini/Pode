//
//  ChildrenView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct ChildrenView: View {
    @Query var children: [Child]
    @Environment(\.modelContext) var modelContext
    
    @State private var viewModel = ChildViewModel()
    
    @State private var presentAddChild: Bool = false
    @State private var selectedChild: Child? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                if children.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma criança",
                        systemImage: "person.2.slash",
                        description: Text("Adicione uma criança para começar.")
                    )
                } else {
                    List(children) { child in
                        ChildCardView(
                            child: child,
                            viewModel: viewModel,
                            selectedChild: $selectedChild
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Crianças")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentAddChild = true
                    } label: {
                        Label("Adicionar Criança", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentAddChild) {
                AddChildView(viewModel: viewModel)
            }
            .sheet(item: $selectedChild) { child in
                EditChildView(
                    child: child,
                    viewModel: viewModel
                )
            }
        }
    }
}

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
    
    @State private var presentAddChild: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(children) { child in
                    ChildCardView(child: child)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
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
                AddChildView()
            }
        }
    }
}

////
////  ChildrenView.swift
////  Pode?
////
////  Created by Marlon Ribas on 15/04/26.
////
//
//import SwiftUI
//import SwiftData
//
//struct ChildrenView: View {
//    @Query var children: [Child]
//    @Environment(\.modelContext) var modelContext
//    
//    @State private var viewModel = ChildViewModel()
//    
//    @State private var presentAddChild: Bool = false
//    @State private var selectedChild: Child? = nil
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if children.isEmpty {
//                    ContentUnavailableView(
//                        "Nenhuma criança",
//                        systemImage: "person.2.slash",
//                        description: Text("Adicione uma criança para começar.")
//                    )
//                } else {
//                    List(children) { child in
//                        ChildCardView(
//                            child: child,
//                            viewModel: viewModel,
//                            selectedChild: $selectedChild
//                        )
//                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.clear)
//                        .swipeActions {
//                            Button(role: .destructive) {
//                                // MUDAR ISSO
//                                modelContext.delete(child)
//                                do {
//                                    try modelContext.save()
//                                } catch {
//                                    print("Failed to delete child: \(error)")
//                                }
//                            } label: {
//                                Label("Excluir", systemImage: "trash")
//                            }
//                            
//                            Button {
//                                selectedChild = child
//                            } label: {
//                                Label("Editar", systemImage: "pencil")
//                            }
//                            .tint(.blue)
//                        }
//                    }
//                    .listStyle(.plain)
//                    .scrollContentBackground(.hidden)
//                    .background(Color(.systemGroupedBackground))
//                }
//            }
//            .navigationTitle("Crianças")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        presentAddChild = true
//                    } label: {
//                        Label("Adicionar Criança", systemImage: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $presentAddChild) {
//                AddChildView(viewModel: viewModel)
//            }
//            .sheet(item: $selectedChild) { child in
//                EditChildView(
//                    child: child,
//                    viewModel: viewModel
//                )
//            }
//        }
//    }
//}

import SwiftUI
import SwiftData

struct ChildrenView: View {
    @Query var children: [Child]
    @Environment(\.modelContext) var modelContext

    @State private var viewModel = ChildViewModel()
    @State private var presentAddChild: Bool = false
    @State private var selectedChild: Child? = nil
    @State private var appear = false

    var body: some View {
        NavigationStack {
            Group {
                if children.isEmpty {
                    emptyState
                } else {
                    childrenList
                }
            }
            .background(
                MeshGradient(width: 3,
                             height: 3,
                             points: [
                                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                                [0.0, 0.5], appear ? [0.5, 0.5] : [0.8, 0.2], [1.0, 0.5],
                                [0.0, 1.0], [appear ? 0.5 : 1.0, 1.0], [1.0, 1.0],
                             ], colors: [
                                appear ? .teal.opacity(0.2) : .teal.opacity(0.2), Color.accentColor.opacity(0.2), .blue.opacity(0.05),
                                Color.accentColor.opacity(0.3), .teal.opacity(0.1), Color.accentColor.opacity(0.2),
                                Color.accentColor.opacity(0.05), .teal.opacity(0.05), appear ? .teal.opacity(0.3) : Color.accentColor.opacity(0.05)
                             ])
                .ignoresSafeArea()
            )
            .navigationTitle("Crianças")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
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
                EditChildView(child: child, viewModel: viewModel)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    appear.toggle()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ChildrenView {

    var emptyState: some View {
        ContentUnavailableView {
            Label("Nenhuma criança", systemImage: "person.2.slash")
        } description: {
            Text("Adicione uma criança para começar a analisar alimentos.")
        }
    }

    var childrenList: some View {
        List {
            Section {
                ForEach(children) { child in
                    ChildCardView(
                        child: child,
                        viewModel: viewModel,
                        selectedChild: $selectedChild
                    )
                    .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.removeChild(child, context: modelContext)
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }

                        Button {
                            selectedChild = child
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.accentColor)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

//
//  PermittedFoodView.swift
//  Pode?
//
//  Created by Gabriel Gardini on 21/04/26.
//

import SwiftUI
import SwiftData

struct PermittedFoodView: View {
    @State private var model = PermittedFoodViewModel()
    
    @Query var children: [Child]
    
    private var allChildren: [Child] {
        children
            .filter { $0.age <= 24 }
            .sorted { $0.age < $1.age }
    }
    
    @Environment(\.modelContext) var modelContext
    
    @State private var appear = false
    
    var body: some View {
        NavigationStack {
            Group {
                if allChildren.isEmpty {
                    emptyState
                } else {
                    content
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
            .navigationTitle("Guia")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle("Mostrando crianças de até 2 anos")
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    appear.toggle()
                }
            }
        }
    }
    
    private func scrollToChildMonth(_ month: Int?, proxy: ScrollViewProxy) {
        guard let month,
              let target = model.timeline.first(where: { $0.contains(month: month) }) else {
            return
        }
        
        withAnimation(.snappy) {
            proxy.scrollTo("month-\(target.month)", anchor: .top)
        }
    }
    
    private func status(for item: MonthlyPermission) -> TimelineStatus {
        let currentMonth = model.selectedChild?.age ?? 0
        let endMonth = item.endMonth ?? item.month
        
        if currentMonth > endMonth {
            return .past
        } else if item.contains(month: currentMonth) {
            return .current
        } else {
            return .future
        }
    }
}

private extension PermittedFoodView {
    
    var emptyState: some View {
        ContentUnavailableView(
            "Nenhuma criança cadastrada",
            systemImage: "figure.2.and.child.holdinghands",
            description: Text("Adicione uma criança para ver o guia de alimentos.")
        )
    }
    
    var content: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: 8)
                        .id("timeline-top")
                    
                    ForEach(Array(model.timeline.enumerated()), id: \.element.id) { index, item in
                        MonthTimelineRow(
                            item: item,
                            status: status(for: item),
                            isLast: index == model.timeline.count - 1
                        )
                        .id("month-\(item.month)")
                    }
                    VStack {
                        Text("As recomendações deste guia são baseadas no [Guia Alimentar para Crianças Brasileiras Menores de 2 Anos](https://bvsms.saude.gov.br/bvs/publicacoes/guia_alimentar_crianca_brasileira_versao_resumida.pdf), do Ministério da Saúde.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            
            .toolbar {
                if !allChildren.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(allChildren) { child in
                                Button {
                                    withAnimation(.snappy) {
                                        model.selectedChild = child
                                    }
                                    
                                    scrollToChildMonth(child.age, proxy: proxy)
                                } label: {
                                    if child.id == model.selectedChild?.id {
                                        Label(child.name, systemImage: "checkmark")
                                    } else {
                                        Text(child.name)
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
            .onAppear {
                if model.selectedChild == nil {
                    model.selectedChild = allChildren.first
                }
                
                if let month = model.selectedChild?.age {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        scrollToChildMonth(month, proxy: proxy)
                    }
                }
            }
            .onChange(of: model.selectedChild) { _, newValue in
                scrollToChildMonth(newValue?.age, proxy: proxy)
            }
        }
    }
}

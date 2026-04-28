//
//  PermittedFoodView.swift
//  Pode?
//
//  Created by Gabriel Gardini on 21/04/26.
//

import SwiftUI
import SwiftData

// MARK: - Main View
struct PermittedFoodView: View {
    @State private var model = PermittedFoodViewModel()
    
    @Query var children: [Child]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Color.clear
                            .frame(height: 8)
                            .id("timeline-top")
                        
                        if children.isEmpty {
                            ContentUnavailableView(
                                "Nenhuma criança cadastrada",
                                systemImage: "figure.2.and.child.holdinghands",
                                description: Text("Adicione uma criança para ver o guia de alimentos.")
                            )
                        } else if model.selectedChild != nil && (model.selectedChild?.age ?? 0) >= 24 {
                            ContentUnavailableView(
                                "Fora da faixa etária",
                                systemImage: "calendar.badge.exclamationmark",
                                description: Text("Este guia é válido para crianças até 24 meses.")
                            )
                        } else {
                            ForEach(Array(model.timeline.enumerated()), id: \.element.id) { index, item in
                                MonthTimelineRow(
                                    item: item,
                                    status: status(for: item),
                                    isLast: index == model.timeline.count - 1
                                )
                                .id("month-\(item.month)")
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
                .navigationTitle("Guia")
                
                .toolbar {
                    if !children.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                ForEach(children) { child in
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
                        model.selectedChild = children.first
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

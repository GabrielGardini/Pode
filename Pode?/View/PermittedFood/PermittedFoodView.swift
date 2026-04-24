//
//  PermittedFoodView.swift
//  Pode?
//
//  Created by Gabriel Gardini on 21/04/26.
//

import SwiftUI
import SwiftData

// MARK: - Pills Style
struct ChildPill: View {
    let child: ChildPermittedFood
    let isSelected: Bool

    var body: some View {
        Text(child.name)
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray3), lineWidth: 1)
            )
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Timeline Status
enum TimelineStatus {
    case past
    case current
    case future

    var color: Color {
        switch self {
        case .past:
            return .green
        case .current:
            return .blue
        case .future:
            return .red
        }
    }
}

// MARK: - Timeline Row
struct MonthTimelineRow: View {
    let item: MonthlyPermission
    let status: TimelineStatus
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 0) {
                Circle()
                    .fill(status.color)
                    .frame(
                        width: status == .current ? 30 : 24,
                        height: status == .current ? 30 : 24
                    )
                    .overlay {
                        if status == .current {
                            Circle()
                                .stroke(status.color.opacity(0.16), lineWidth: 8)
                        }
                    }

                if !isLast {
                    Rectangle()
                        .fill(status.color)
                        .frame(width: 3)
                        .frame(minHeight: 96)
                        .opacity(status == .future ? 0.35 : 1)
                }
            }
            .frame(width: 34)

            VStack(alignment: .leading, spacing: 10) {
                Text(item.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(status == .future ? .secondary : .primary)

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(item.permittedFoods) { food in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.name)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(status == .future ? .secondary : .primary)

                            if let notes = food.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.subheadline.italic())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 28)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Main View
struct PermittedFoodView: View {
    @State private var model = PermittedFoodViewModel()

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: 24)
                        .id("timeline-top")

                    ForEach(Array(model.timeline.enumerated()), id: \.element.id) { index, item in
                        MonthTimelineRow(
                            item: item,
                            status: status(for: item),
                            isLast: index == model.timeline.count - 1
                        )
                        .id("month-\(item.month)")
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if model.children.isEmpty {
                                Text("Nenhuma criança cadastrada")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(model.children) { child in
                                    Button {
                                        withAnimation(.snappy) {
                                            model.selectedChild = child
                                        }

                                        scrollToChildMonth(child.monthsOld, proxy: proxy)
                                    } label: {
                                        ChildPill(
                                            child: child,
                                            isSelected: child.id == model.selectedChild?.id
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }

                    Divider()
                }
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Alimentos Permitidos")
            .onAppear {
                model.loadChildren(from: modelContext)

                if model.selectedChild == nil {
                    model.selectedChild = model.children.first
                }

                if let month = model.selectedChild?.monthsOld {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        scrollToChildMonth(month, proxy: proxy)
                    }
                }
            }
            .onChange(of: model.selectedChild) { _, newValue in
                scrollToChildMonth(newValue?.monthsOld, proxy: proxy)
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
        let currentMonth = model.selectedChild?.monthsOld ?? 0
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

// MARK: - Preview
#Preview {
    NavigationStack {
        PermittedFoodView()
    }
}

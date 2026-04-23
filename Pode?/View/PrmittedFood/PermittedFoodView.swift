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
                Capsule().fill(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
            )
            .overlay(
                Capsule().stroke(isSelected ? Color.accentColor : Color(.systemGray3), lineWidth: 1)
            )
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Timeline Row
struct MonthTimelineRow: View {
    let item: MonthlyPermission
    let isCurrentForChild: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline rail with bullet
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2)
                    .opacity(0.7)
                // The bullet sits centered relative to the row content height using overlay later
            }
            .frame(width: 2)
            .overlay(
                ZStack {
                    Circle()
                        .fill(isCurrentForChild ? Color.accentColor.opacity(0.15) : Color(.systemBackground))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(isCurrentForChild ? Color.accentColor : Color(.systemGray3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(isCurrentForChild ? 0.12 : 0), radius: 6, x: 0, y: 2)
                    Circle()
                        .fill(isCurrentForChild ? Color.accentColor : Color(.systemGray3))
                        .frame(width: 8, height: 8)
                }
                .frame(width: 44, height: 44)
                , alignment: .top
            )

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("\(item.month) meses")
                    .font(.headline)
                    .foregroundStyle(isCurrentForChild ? Color.accentColor : Color.primary)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(item.permittedFoods) { food in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(food.name)
                                .font(.subheadline.weight(.semibold))
                            if let notes = food.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Main View
struct PermittedFoodView: View {
    @State private var model = PermittedFoodViewModel()
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // Pills selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(model.children) { child in
                            Button {
                                withAnimation(.snappy) {
                                    model.selectedChild = child
                                }
                                if let m = model.selectedChild?.monthsOld {
                                    withAnimation(.snappy) {
                                        proxy.scrollTo("month-\(m)", anchor: .top)
                                    }
                                }
                            } label: {
                                ChildPill(child: child, isSelected: child == model.selectedChild)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.ultraThinMaterial)

                Divider()

                // Timeline
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(model.timeline) { item in
                            MonthTimelineRow(
                                item: item,
                                isCurrentForChild: item.month == (model.selectedChild?.monthsOld ?? -1)
                            )
                            .padding(.horizontal)
                            .id("month-\(item.month)")
                        }
                    }
                    .padding(.vertical)
                }
            }
            .onAppear {
                #if canImport(SwiftData)
                model.loadChildren(from: modelContext)
                #else
                model.loadChildrenFromDatabase()
                #endif
            }
            .navigationTitle("Alimentos Permitidos")
            .toolbarTitleDisplayMode(.inline)
            .onChange(of: model.selectedChild) { _, newValue in
                if let m = newValue?.monthsOld {
                    withAnimation(.snappy) {
                        proxy.scrollTo("month-\(m)", anchor: .top)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PermittedFoodView()
    }
}

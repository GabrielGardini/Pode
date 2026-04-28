//
//  MonthTimelineRow.swift
//  Pode?
//
//  Created by Marlon Ribas on 28/04/26.
//

import SwiftUI

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
    
    var dotSize: CGFloat {
        self == .current ? 14 : 10
    }
}

struct FoodRowView: View {
    let food: PermittedFood
    let status: TimelineStatus

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(status == .past ? .green : status == .current ? .accentColor : Color(.systemGray4))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(food.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(status == .future ? .tertiary : .primary)

                if let notes = food.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Timeline Row

struct MonthTimelineRow: View {
    let item: MonthlyPermission
    let status: TimelineStatus
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // Connector + dot
            VStack(spacing: 0) {
                ZStack {
                    if status == .current {
                        Circle()
                            .fill(status.color.opacity(0.15))
                            .frame(width: 28, height: 28)
                    }
                    Circle()
                        .fill(status.color)
                        .frame(width: status.dotSize, height: status.dotSize)
                }
                .frame(width: 28, height: 28)

                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [status.color.opacity(status == .future ? 0.2 : 0.4), status.color.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(minHeight: 80)
                }
            }

            // Content card
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(status == .future ? .secondary : .primary)

                    Spacer()

                    if status == .current {
                        Text("Agora")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    } else if status == .past {
                        Text("Liberado")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.1), in: Capsule())
                    }
                }
                .padding(.bottom, item.permittedFoods.isEmpty ? 0 : 12)

                if !item.permittedFoods.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(item.permittedFoods) { food in
                            FoodRowView(food: food, status: status)
                        }
                    }
                } else {
                    Text("Nenhum alimento listado")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(status == .current ? 0.06 : 0.03), radius: status == .current ? 8 : 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(status == .current ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
    }
}

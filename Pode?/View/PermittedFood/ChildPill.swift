//
//  ChildPill.swift
//  Pode?
//
//  Created by Marlon Ribas on 28/04/26.
//

import SwiftUI

struct ChildPill: View {
    let child: Child
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

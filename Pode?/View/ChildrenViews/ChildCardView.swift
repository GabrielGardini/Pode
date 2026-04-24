//
//  ChildCardView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI

struct ChildCardView: View {
    @Environment(\.modelContext) var modelContext
    
    let child: Child
    var viewModel: ChildViewModel
    
    @Binding var selectedChild: Child?
    
    @State private var isPressed = false

    var body: some View {
        HStack {
            
            // Ícone
            Image(systemName: iconForAge(child.age / 12))
                .font(.largeTitle)
                .foregroundStyle(Color.accentColor)
                .padding(.leading, 24)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                
                Text(child.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(Child.ageDisplay(age: child.age))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Spacer()
        }
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .contextMenu {
            Button {
                selectedChild = child
            } label: {
                Label("Editar", systemImage: "pencil")
            }

            Button(role: .destructive) {
                viewModel.removeChild(child, context: modelContext)
            } label: {
                Label("Excluir", systemImage: "trash")
            }
        }
    }
    
    func iconForAge(_ age: Int) -> String {
        switch age {
        case 0...2:
            return "figure.and.child.holdinghands"
        default:
            return "figure.child"
        }
    }
}

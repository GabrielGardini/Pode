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
            Image(systemName: iconForAge(child.age))
                .font(.largeTitle)
                .foregroundStyle(Color.accentColor)
                .padding(.leading, 24)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                
                Text(child.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(ageDisplay())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !(allergiesText(child.allergies).isEmpty) {
                    Text(allergiesText(child.allergies))
                        .font(.body)
                        .foregroundStyle(.orange)
                }
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
}

extension ChildCardView {
    
    func ageDisplay() -> String {
        let age = child.age
        
        if age < 12 {
            let monthText = age == 1 ? "mês" : "meses"
            return "\(age) \(monthText)"
        }
        
        let years = age / 12
        let months = age % 12
        
        let yearText = years == 1 ? "ano" : "anos"
        
        if months == 0 {
            return "\(years) \(yearText)"
        }
        
        let monthText = months == 1 ? "mês" : "meses"
        return "\(years) \(yearText) e \(months) \(monthText)"
    }
    
    func monthsBetween(_ from: Date, _ to: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: from, to: to)
        return max(0, components.month ?? 0)
    }
    
    func allergiesText(_ allergies: [String]) -> String {
        let preview = allergies.prefix(2).joined(separator: ", ")
        
        if allergies.count > 2 {
            return "\(preview) +\(allergies.count - 2)"
        } else {
            return preview
        }
    }
}

extension ChildCardView {
    
    func iconForAge(_ age: Int) -> String {
        switch age {
        case 0...2:
            return "figure.and.child.holdinghands"
        case 3...5:
            return "figure.play"
        default:
            return "backpack"
        }
    }
}

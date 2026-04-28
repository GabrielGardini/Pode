//
//  ChildWheelPickerSheet.swift
//  Pode?
//
//  Created by Marlon Ribas on 28/04/26.
//

import SwiftUI
import SwiftData

struct ChildWheelPickerSheet: View {
    let children: [Child]
    @Binding var selectedChild: Child?
    let onSelect: (Child) -> Void
 
    @Environment(\.dismiss) private var dismiss
    @State private var pickerSelection: Child.ID?
 
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Selecionar criança")
                    .font(.headline)
                Spacer()
                Button("OK") {
                    if let id = pickerSelection,
                       let child = children.first(where: { $0.id == id }) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedChild = child
                        }
                        onSelect(child)
                    }
                    dismiss()
                }
                .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)
 
            Divider()
 
            Picker("Criança", selection: Binding(
                get: { pickerSelection ?? selectedChild?.id },
                set: { pickerSelection = $0 }
            )) {
                ForEach(children) { child in
                    Text(child.name).tag(child.id as Child.ID?)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 8)
        }
        .onAppear {
            pickerSelection = selectedChild?.id
        }
    }
}

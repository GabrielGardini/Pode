//
//  DescriptionView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct DescriptionView: View {
    
    @Binding var description: String
    
    var body: some View {
        VStack(spacing: 16) {
            
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))

            VStack {
                Text("Adicione uma descrição")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextEditor(text: $description)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button(action: {
                    // ação
                }) {
                    Text("Continuar")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(description.isEmpty)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial)
        }
    }
}

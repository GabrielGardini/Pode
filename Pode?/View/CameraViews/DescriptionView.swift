//
//  DescriptionView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct DescriptionView: View {
    
    @Binding var result: ScanResult
    let onComplete: () -> Void
    
    @State private var descriptionText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer(minLength: 0)
            
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 8)
            
            VStack(spacing: 8) {
                Text("Descreva o alimento")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Informe o nome ou descreva do que se trata.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            VStack {
                TextField("Ex: biscoitos, snacks e outros", text: $descriptionText)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            
            Spacer(minLength: 0)
            
            Button {
                result.description = descriptionText
                onComplete()
            } label: {
                Label("Analisar", systemImage: "sparkles")
                    .padding(8)
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .disabled(descriptionText.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .navigationTitle("Descrição")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
}

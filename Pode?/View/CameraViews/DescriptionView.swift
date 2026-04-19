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
    
    var body: some View {
        VStack(spacing: 32) {
            
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 72))
                .foregroundStyle(Color.accentColor)
            
            VStack(alignment: .leading) {
                Text("Adicione uma descrição")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Informe o nome do alimento ou descreva do que se trata.")
                    .foregroundColor(.gray)
                
                TextField("Descrição", text: $descriptionText)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(32)
            }
            
            Spacer()
            
            Button {
                result.description = descriptionText
                onComplete()
            } label: {
                Text("Analisar")
                    .padding(8)
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .disabled(descriptionText.isEmpty)
        }
        .padding(32)
    }
}

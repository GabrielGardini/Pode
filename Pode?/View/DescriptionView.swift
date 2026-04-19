//
//  DescriptionView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct DescriptionView: View {
    
    @Binding var result: ScanResult
    
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
                    .font(.title2)
                    .foregroundColor(.gray)
                
                TextField("Descrição", text: $result.description)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(32)
            }
            Spacer()
            
            Button {
                print("Continuar!!!!!!!!")
            } label: {
                Text("Analisar")
                    .font(.headline)
                    .padding(8)
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .disabled(result.description.isEmpty)
            
        }
        .padding(.horizontal, 32)
    }
}

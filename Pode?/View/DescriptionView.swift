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
        VStack(spacing: 16) {
            
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
            
            VStack(alignment: .leading) {
                Text("Adicione uma descrição")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Você pode colocar o nome do alimento ou especificar sobre o que ele é.")
                    .font(.body)
                    .foregroundColor(.gray)
                
                TextField("Descrição", text: $result.description)
                    .padding()
                    .background(.secondary)
            }
            Spacer()
            
            Button {
                print("Continuar!!!!!!!!")
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(result.description.isEmpty ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(result.description.isEmpty ? .primary : Color.accentColor)
                    .cornerRadius(32)
            }
            .disabled(result.description.isEmpty)
        }
        .padding()
    }
}

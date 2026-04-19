//
//  PhotoPreviewView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI
import AVFoundation

struct PhotoPreviewView: View {
    
    let item: IdentifiableImage
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button("Retake") {
                    onDismiss()
                }
                .padding()
                
                Spacer()
                
                Button("Save") {
                    print("Aqui será o próximo passo")
                    onDismiss()
                }
                .padding()
                
            }
            .background(.ultraThinMaterial)
            
            Image(uiImage: item.image)
                .resizable()
                .scaledToFit()
            
            Spacer()
        }
    }
    
}

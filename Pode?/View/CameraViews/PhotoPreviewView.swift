//
//  PhotoPreviewView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct PhotoPreviewView: View {
    
    @Binding var result: ScanResult
    let onNext: () -> Void
    let onRetake: () -> Void
    
    var body: some View {
        VStack {
            if let image = result.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                    .transition(.opacity.combined(with: .scale))
            } else {
                ContentUnavailableView("Sem imagem", systemImage: "photo")
            }
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onRetake()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    onNext()
                }
            }
        }
    }
}

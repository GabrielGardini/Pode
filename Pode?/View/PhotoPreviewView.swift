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
                    .scaledToFit()
            }
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Refazer") {
                    onRetake()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    onNext()
                }
            }
        }
    }
}

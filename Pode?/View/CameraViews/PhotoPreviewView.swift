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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onRetake()
                } label: {
                    Image(systemName: "arrow.trianglehead.clockwise")
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

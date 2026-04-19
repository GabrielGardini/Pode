//
//  PhotoPreviewView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct PhotoPreviewView: View {
            
    @Binding var result: ScanResult?
    @Binding var showPreview: Bool
    @Binding var goToDescription: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if let result {
                    Image(uiImage: result.image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        result = nil
                        showPreview = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        showPreview = false
                        goToDescription = true
                    }
                }
            }
        }
    }
}

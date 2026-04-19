//
//  ScannerView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct ScanResult {
    var image: UIImage
    var description: String = ""
}

struct ScannerView: View {
    
    @State private var result: ScanResult?
    @State private var showPreview = false
    @State private var goToDescription = false
    
    var body: some View {
        NavigationStack {
            CameraTest { image in
                result = ScanResult(image: image)
                showPreview = true
            }
            .sheet(isPresented: $showPreview) {
                if let result {
                    PhotoPreviewView(
                        result: Binding(
                            get: { result },
                            set: { self.result = $0 }
                        ),
                        showPreview: $showPreview,
                        goToDescription: $goToDescription)
                }
            }
            .navigationDestination(isPresented: $goToDescription) {
                if let result {
                    DescriptionView(
                        result: Binding(
                            get: { result },
                            set: { self.result = $0 }
                        )
                    )
                }
            }
        }
    }
}

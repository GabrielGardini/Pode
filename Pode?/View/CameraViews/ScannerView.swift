//
//  ScannerView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct ScannerView: View {
    
    @Binding var result: ScanResult
    let onCapture: () -> Void
    
    var body: some View {
        CameraTest { image in
            result.image = image
            onCapture()
        }
        .navigationTitle("Câmera")
        .navigationBarTitleDisplayMode(.inline)
    }
}

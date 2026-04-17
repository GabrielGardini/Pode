//
//  CameraView.swift
//  Pode?
//
//  Created by Marlon Ribas on 14/04/26.
//

import SwiftUI
import AVFoundation

// MARK: - Bridge SwiftUI <-> UIKit
struct CameraView: UIViewControllerRepresentable {

    // Callback para devolver a imagem capturada (em Data)
    var onPhotoCaptured: (Data) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onPhotoCaptured = onPhotoCaptured
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

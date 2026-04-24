//
//  CameraTest.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI
import AVFoundation
import AVKit

struct CameraTest: View {
    
    @StateObject private var cameraManager = CameraManager()
    
    let onCapture: (UIImage) -> Void
    
    var body: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
            } else if cameraManager.authorizationStatus == .notDetermined {
                EmptyView()
            } else {
                VStack(spacing: 16) {
                    ContentUnavailableView(
                        "Acesso à câmera necessário",
                        systemImage: "camera.fill",
                        description: Text("Por favor ative a câmera nas configurações.")
                    )
                    
                    if cameraManager.authorizationStatus == .denied {
                        Button("Abrir configurações") {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                        .buttonStyle(.glassProminent)
                        .padding(.vertical, 16)
                    }
                }
            }
            
            // Botão de captura
            if cameraManager.authorizationStatus == .authorized {
                VStack {
                    Spacer()
                    
                    Button {
                        cameraManager.capturePhoto()
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            cameraManager.checkAuthorization()
        }
        .onChange(of: cameraManager.capturedImage) { oldValue, newValue in
            if let image = newValue?.image {
                onCapture(image)
                cameraManager.capturedImage = nil
            }
        }
    }
}

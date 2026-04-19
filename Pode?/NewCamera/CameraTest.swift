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
    
    var body: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    VStack(spacing: 0) {
                        Text("Acesso à câmera necessário")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        if cameraManager.authorizationStatus == .denied {
                            Text("Por favor ative a câmera nas configurações.")
                                .font(.callout)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button("Abrir configurações") {
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsURL)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.vertical, 16)
                            
                        }
                    }
                }
            }
            
            // Botão de captura
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
            .sheet(item: $cameraManager.capturedImage) { item in
                PhotoPreviewView(item: item, onDismiss: {
                    cameraManager.capturedImage = nil
                })
            }
            
        }
        .onAppear {
            cameraManager.checkAuthorization()
        }
        .padding()
    }
}

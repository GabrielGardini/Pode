//
//  CameraManager.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var capturedImage: IdentifiableImage?
    @Published var isSessionRunning = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    // Componentes do AVFoundation
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.customcamera.sessionQueue")
    
    override init() {
        super.init()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationStatus = .authorized
            setupSession()
        case .notDetermined:
            authorizationStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            authorizationStatus = .denied
        @unknown default:
            authorizationStatus = .denied
        }
    }
    
    private func setupSession() {
        sessionQueue.async {
            [weak self] in guard let self else { return }
            
            // Configurando o presset da session
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // Input da câmera
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? (AVCaptureDeviceInput(device: camera)) else {
                print("Falha ao acessar a câmera")
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.currentInput = input
            }
            
            // Adicionando o output da câmera
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            self.session.commitConfiguration()
            
            // Começo da session
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
            
        }
    }
    
    func capturePhoto() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            // Configuração do photo settings
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            
            if self.photoOutput.isHighResolutionCaptureEnabled {
                settings.isHighResolutionPhotoEnabled = true
            }
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Erro na captura da foto: \(error.localizedDescription)")
            return
        }
        
        // Extração dos dados da imagem
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("Falha ao converter")
            return
        }
        
        // Atualiza a UI na main thread
        DispatchQueue.main.async {
            [weak self] in
            self?.capturedImage = IdentifiableImage(image: uiImage)
        }
    }
}

struct IdentifiableImage: Identifiable {
    var id = UUID()
    let image: UIImage
}

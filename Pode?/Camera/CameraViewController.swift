//
//  CameraViewController.swift
//  Pode?
//
//  Created by Marlon Ribas on 14/04/26.
//

import SwiftUI
import AVFoundation

class CameraViewController: UIViewController {

    // Sessão principal da câmera
    var captureSession: AVCaptureSession!

    // Preview da câmera
    var previewLayer: AVCaptureVideoPreviewLayer!

    // Output responsável por capturar fotos
    var photoOutput: AVCapturePhotoOutput!

    // Callback para enviar a imagem capturada
    var onPhotoCaptured: ((Data) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupCaptureButton()
    }

    // MARK: - Configuração da câmera
    func setupCamera() {

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        // Seleciona câmera traseira
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("Erro ao acessar câmera")
            return
        }
        
        // MARK: - CONFIGURAÇÃO AVANÇADA DA CÂMERA
        do {
            try device.lockForConfiguration()

            // 🔍 FOCO CONTÍNUO
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            // 🎯 FOCO NO CENTRO
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }

            // 🔎 FOCO PRÓXIMO (macro - MUITO IMPORTANTE)
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }

            // 💡 EXPOSIÇÃO CONTÍNUA
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            // 🎯 EXPOSIÇÃO NO CENTRO
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }

            // 🔥 REDUZ ESTOURO DE BRANCO (evita reflexo)
            device.setExposureTargetBias(-0.3)

            device.unlockForConfiguration()

        } catch {
            print("Erro ao configurar câmera: \(error)")
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

        } catch {
            print("Erro ao criar input: \(error)")
            return
        }

        // MARK: - Configura saída de foto
        photoOutput = AVCapturePhotoOutput()
        
        // Prioriza qualidade máxima da foto
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        if let connection = photoOutput.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
            
            // Garante orientação correta
            connection.videoRotationAngle = 90
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        // MARK: - Preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        // Inicie a sessão em uma fila de fundo para evitar travar a UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    // MARK: - Botão de captura
    func setupCaptureButton() {

        let button = UIButton(type: .system)

        // Estilo do botão (círculo branco tipo câmera)
        button.frame = CGRect(x: view.frame.midX - 35, y: view.frame.height - 170, width: 70, height: 70)
        button.layer.cornerRadius = 35
        button.backgroundColor = .white

        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        view.addSubview(button)
    }

    // MARK: - Captura da foto
    @objc func capturePhoto() {

        let settings = AVCapturePhotoSettings()

        // Prioriza qualidade
        settings.photoQualityPrioritization = .quality

        // Desliga flash (evita reflexo)
        settings.flashMode = .off

        // Dispara a captura
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        if let error = error {
            print("Erro ao capturar foto: \(error)")
            return
        }

        // Converte a foto capturada para Data (JPEG)
        guard let imageData = photo.fileDataRepresentation() else {
            print("Erro ao converter imagem")
            return
        }

        // Retorna a imagem via callback
        onPhotoCaptured?(imageData)

        // Fecha a tela da câmera
        dismiss(animated: true)
    }
}

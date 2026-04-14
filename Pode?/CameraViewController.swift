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

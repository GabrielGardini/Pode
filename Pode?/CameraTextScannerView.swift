import SwiftUI
import AVFoundation
import Vision
import Combine

final class CameraSessionController: NSObject, ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var recognizedText: String = ""

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private var videoOutput = AVCaptureVideoDataOutput()
    private var requests: [VNRequest] = []

    override init() {
        super.init()
        setupVision()
        checkAuthorization()
    }

    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                }
                if granted {
                    self.configureSession()
                }
            }
        default:
            DispatchQueue.main.async { self.isAuthorized = false }
        }
    }

    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            // Input
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)

            // Output
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoOutputQueue"))
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
            if let connection = self.videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    private func setupVision() {
        let request = VNRecognizeTextRequest(completionHandler: self.handleRecognizedText)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["pt-BR", "en-US"]
        self.requests = [request]
    }

    private func handleRecognizedText(request: VNRequest, error: Error?) {
        guard error == nil else { return }
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        let strings: [String] = observations.compactMap { obs in
            return obs.topCandidates(1).first?.string
        }
        let text = strings.joined(separator: "\n")
        DispatchQueue.main.async { [weak self] in
            self?.recognizedText = text
        }
    }

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
}

extension CameraSessionController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var requestOptions: [VNImageOption: Any] = [:]
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
        do {
            try handler.perform(self.requests)
        } catch {
            // ignore frame errors
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var controller: CameraSessionController

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = controller.makePreviewLayer()
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

struct CameraTextScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = CameraSessionController()
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .bottom) {
            if controller.isAuthorized {
                CameraPreviewView(controller: controller)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                    Text("Permita o acesso à câmera em Ajustes")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }

            VStack(spacing: 8) {
                Text("Texto reconhecido (prévia)")
                    .font(.headline)
                    .padding(.top, 12)
                ScrollView {
                    Text(controller.recognizedText.isEmpty ? "Aponte para a tabela nutricional" : controller.recognizedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .frame(height: 180)
                HStack {
                    Button(role: .cancel) { dismiss() } label: {
                        Label("Cancelar", systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        text = controller.recognizedText
                        dismiss()
                    } label: {
                        Label("Usar texto", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(controller.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(
                LinearGradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .onReceive(controller.$recognizedText) { newValue in
            // Could add throttling or post-processing here if desired
        }
    }
}


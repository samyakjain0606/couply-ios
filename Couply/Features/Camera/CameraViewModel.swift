import SwiftUI
import AVFoundation
import Combine

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isCapturing = false
    @Published var capturedImage: CapturedImage?
    @Published var selectedImage: UIImage?
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var showPhotoPicker = false
    @Published var showPermissionAlert = false
    @Published var error: String?

    // MARK: - Camera Properties
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentCameraPosition: AVCaptureDevice.Position = .front
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

    // MARK: - Initialization
    override init() {
        super.init()
    }

    // MARK: - Permissions
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }

    // MARK: - Camera Setup
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Add video input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }

        session.commitConfiguration()

        // Start session on background thread
        Task.detached(priority: .userInitiated) {
            self.session.startRunning()
        }
    }

    // MARK: - Capture Photo
    func capturePhoto() {
        guard !isCapturing else { return }

        isCapturing = true

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode

        // Check if front camera (need to mirror)
        let isFrontCamera = currentCameraPosition == .front

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Flip Camera
    func flipCamera() {
        session.beginConfiguration()

        // Remove existing input
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }

        // Switch position
        currentCameraPosition = currentCameraPosition == .front ? .back : .front

        // Add new input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        session.commitConfiguration()
    }

    // MARK: - Toggle Flash
    func toggleFlash() {
        flashMode = flashMode == .on ? .off : .on
    }

    // MARK: - Send Photo
    func sendPhoto(caption: String?) async {
        guard let image = capturedImage?.image else { return }

        do {
            _ = try await PhotoService.shared.uploadPhoto(image: image, caption: caption)
            capturedImage = nil
            CouplyHaptics.success()
        } catch {
            self.error = error.localizedDescription
            CouplyHaptics.error()
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            self.isCapturing = false

            if let error = error {
                self.error = error.localizedDescription
                return
            }

            guard let imageData = photo.fileDataRepresentation(),
                  var image = UIImage(data: imageData) else {
                return
            }

            // Mirror front camera images
            if currentCameraPosition == .front {
                image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
            }

            // Fix orientation
            image = image.fixOrientation()

            self.capturedImage = CapturedImage(image: image)
        }
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}

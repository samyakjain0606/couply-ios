import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @EnvironmentObject var authService: AuthService

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()

            // Vignette overlay
            RadialGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                center: .center,
                startRadius: 150,
                endRadius: 400
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                // Top controls
                HStack {
                    // Flash button
                    Button {
                        CouplyHaptics.light()
                        viewModel.toggleFlash()
                    } label: {
                        Image(systemName: viewModel.flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(CouplyIconButtonStyle())

                    Spacer()

                    // Partner indicator
                    if let partner = authService.partner {
                        PartnerIndicator(partner: partner)
                    }

                    Spacer()

                    // Filters button (placeholder)
                    Button {
                        CouplyHaptics.light()
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(CouplyIconButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Bottom controls
                HStack(alignment: .center, spacing: 40) {
                    // Gallery button
                    Button {
                        CouplyHaptics.light()
                        viewModel.showPhotoPicker = true
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.couplyPrimaryGradient)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }

                    // Capture button
                    CaptureButton(isCapturing: viewModel.isCapturing) {
                        CouplyHaptics.heavy()
                        viewModel.capturePhoto()
                    }

                    // Flip camera button
                    Button {
                        CouplyHaptics.light()
                        viewModel.flipCamera()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(CouplyIconButtonStyle(size: 50))
                }
                .padding(.bottom, 130)
            }

            // Loading overlay
            if viewModel.isCapturing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            viewModel.checkPermissions()
        }
        .fullScreenCover(item: $viewModel.capturedImage) { image in
            PhotoPreviewView(image: image, onSend: { caption in
                Task {
                    await viewModel.sendPhoto(caption: caption)
                }
            }, onRetake: {
                viewModel.capturedImage = nil
            })
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPicker(image: $viewModel.selectedImage)
        }
        .onChange(of: viewModel.selectedImage) { _, newValue in
            if let image = newValue {
                viewModel.capturedImage = CapturedImage(image: image)
            }
        }
        .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to capture photos.")
        }
    }
}

// MARK: - Partner Indicator
struct PartnerIndicator: View {
    let partner: User

    var body: some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.couplyPrimaryGradient)
                    .frame(width: 32, height: 32)

                Text("😊")
                    .font(.system(size: 16))
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )

            // Name
            Text("Sending to \(partner.displayName)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            // Online indicator
            Circle()
                .fill(Color.couplySuccess)
                .frame(width: 8, height: 8)
                .modifier(PulseModifier())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.15))
        .background(.ultraThinMaterial.opacity(0.5))
        .clipShape(Capsule())
    }
}

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

// MARK: - Capture Button
struct CaptureButton: View {
    let isCapturing: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 4)
                    .frame(width: 80, height: 80)

                // Inner button
                Circle()
                    .fill(Color.couplyPrimaryGradient)
                    .frame(width: 68, height: 68)
                    .scaleEffect(isPressed ? 0.9 : 1.0)

                // Glow effect
                Circle()
                    .fill(Color.couplyHeartbeat.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .shadow(color: Color.couplyHeartbeat.opacity(0.5), radius: 15, y: 5)
        .disabled(isCapturing)
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Photo Picker
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Captured Image Wrapper
struct CapturedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    CameraView()
        .environmentObject(AuthService.shared)
}

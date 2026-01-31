import SwiftUI

struct PhotoPreviewView: View {
    let image: CapturedImage
    let onSend: (String?) -> Void
    let onRetake: () -> Void

    @State private var caption = ""
    @State private var showCaption = false
    @State private var isSending = false
    @State private var offset: CGSize = .zero
    @FocusState private var isCaptionFocused: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Photo
            Image(uiImage: image.image)
                .resizable()
                .scaledToFit()
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                        .onEnded { value in
                            if abs(value.translation.height) > 150 {
                                dismiss()
                                onRetake()
                            } else {
                                withAnimation(.spring()) {
                                    offset = .zero
                                }
                            }
                        }
                )

            // UI Overlay
            VStack {
                // Top bar
                HStack {
                    Button {
                        CouplyHaptics.light()
                        dismiss()
                        onRetake()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Edit buttons
                    HStack(spacing: 16) {
                        ToolButton(icon: "textformat") {
                            withAnimation {
                                showCaption.toggle()
                                isCaptionFocused = showCaption
                            }
                        }

                        ToolButton(icon: "paintbrush.pointed") {
                            // Doodle - Coming soon
                        }

                        ToolButton(icon: "face.smiling") {
                            // Stickers - Coming soon
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Caption input
                if showCaption {
                    TextField("Add a caption...", text: $caption)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .focused($isCaptionFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isCaptionFocused = false
                        }
                }

                // Bottom bar
                HStack(spacing: 20) {
                    // Retake button
                    Button {
                        CouplyHaptics.light()
                        dismiss()
                        onRetake()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24))
                            Text("Retake")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .frame(width: 70)
                    }

                    Spacer()

                    // Send button
                    Button {
                        CouplyHaptics.heavy()
                        sendPhoto()
                    } label: {
                        HStack(spacing: 10) {
                            if isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 22))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.couplyPrimaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: Color.couplyHeartbeat.opacity(0.4), radius: 10)
                    }
                    .disabled(isSending)

                    Spacer()

                    // Save button
                    Button {
                        CouplyHaptics.light()
                        saveToPhotos()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                            Text("Save")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .frame(width: 70)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }

            // Sending overlay
            if isSending {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    SendingAnimation()

                    Text("Sending to your partner...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .onTapGesture {
            isCaptionFocused = false
        }
    }

    private func sendPhoto() {
        isSending = true
        onSend(caption.isEmpty ? nil : caption)

        // Dismiss after a short delay to show animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }

    private func saveToPhotos() {
        UIImageWriteToSavedPhotosAlbum(image.image, nil, nil, nil)
        CouplyHaptics.success()
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
        }
    }
}

// MARK: - Sending Animation
struct SendingAnimation: View {
    @State private var heartOffset: CGFloat = 0
    @State private var heartOpacity: Double = 1
    @State private var heartScale: CGFloat = 1

    var body: some View {
        ZStack {
            // Pulsing circles
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(Color.couplyHeartbeat.opacity(0.3), lineWidth: 2)
                    .frame(width: 80 + CGFloat(index * 30), height: 80 + CGFloat(index * 30))
                    .modifier(PulseCircleModifier(delay: Double(index) * 0.3))
            }

            // Flying heart
            Text("💕")
                .font(.system(size: 40))
                .offset(y: heartOffset)
                .opacity(heartOpacity)
                .scaleEffect(heartScale)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                        heartOffset = -50
                        heartOpacity = 0
                        heartScale = 1.5
                    }
                }
        }
        .frame(width: 150, height: 150)
    }
}

struct PulseCircleModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.8

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    scale = 1.5
                    opacity = 0
                }
            }
    }
}

#Preview {
    PhotoPreviewView(
        image: CapturedImage(image: UIImage(systemName: "photo")!),
        onSend: { _ in },
        onRetake: {}
    )
}

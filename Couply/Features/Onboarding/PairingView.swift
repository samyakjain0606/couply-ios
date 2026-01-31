import SwiftUI

struct PairingView: View {
    @StateObject private var viewModel = PairingViewModel()
    @State private var selectedOption: PairingOption = .sendInvite

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.couplyWarmWhite, Color.couplyPeachLight],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Connect with your partner")
                            .font(.custom("Fraunces", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(.couplyDarkWarm)

                        Text("Link your accounts to start sharing moments")
                            .font(.system(size: 15))
                            .foregroundColor(.couplyWarmGray)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Illustration
                    PairingIllustration()
                        .padding(.vertical, 30)

                    if viewModel.isWaitingForPartner {
                        // Waiting for partner view
                        WaitingForPartnerView(
                            inviteCode: viewModel.inviteCode,
                            onCancel: {
                                viewModel.cancelWaiting()
                            }
                        )
                    } else if viewModel.showCodeEntry {
                        // Enter code view
                        EnterCodeView(
                            code: $viewModel.enteredCode,
                            isLoading: viewModel.isLoading,
                            error: viewModel.error,
                            onSubmit: {
                                Task {
                                    await viewModel.joinWithCode()
                                }
                            },
                            onBack: {
                                viewModel.showCodeEntry = false
                                viewModel.enteredCode = ""
                                viewModel.error = nil
                            }
                        )
                    } else {
                        // Pairing options
                        VStack(spacing: 16) {
                            PairingOptionCard(
                                option: .sendInvite,
                                isSelected: selectedOption == .sendInvite,
                                onTap: { selectedOption = .sendInvite }
                            )

                            PairingOptionCard(
                                option: .enterCode,
                                isSelected: selectedOption == .enterCode,
                                onTap: { selectedOption = .enterCode }
                            )
                        }
                        .padding(.horizontal, 24)

                        Spacer()

                        // Error
                        if let error = viewModel.error {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.couplyError)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                        }

                        // Continue button
                        Button {
                            CouplyHaptics.medium()
                            Task {
                                if selectedOption == .sendInvite {
                                    await viewModel.generateInviteCode()
                                } else {
                                    viewModel.showCodeEntry = true
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Continue")
                            }
                        }
                        .buttonStyle(.couplyPrimary)
                        .disabled(viewModel.isLoading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)

                        // Progress dots
                        ProgressDotsView(currentStep: 2, totalSteps: 4)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Pairing Illustration
struct PairingIllustration: View {
    @State private var heartScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 20) {
            // You
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.couplyPrimaryGradient)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.couplyCoral.opacity(0.3), radius: 10)

                    Text("😊")
                        .font(.system(size: 36))
                }

                Text("You")
                    .font(.system(size: 13))
                    .foregroundColor(.couplyWarmGray)
            }

            // Connection line with heart
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.couplyCoral, Color.couplyLavenderMist],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 50, height: 3)
                    .clipShape(Capsule())

                Text("💕")
                    .font(.system(size: 20))
                    .scaleEffect(heartScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            heartScale = 1.3
                        }
                    }
            }

            // Partner
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.couplyLavenderMist)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 3, dash: [8, 6])
                                )
                                .foregroundColor(.couplyRose)
                        )

                    Text("❓")
                        .font(.system(size: 36))
                }

                Text("Partner")
                    .font(.system(size: 13))
                    .foregroundColor(.couplyWarmGray)
            }
        }
    }
}

// MARK: - Pairing Option
enum PairingOption {
    case sendInvite
    case enterCode

    var icon: String {
        switch self {
        case .sendInvite: return "📤"
        case .enterCode: return "🔑"
        }
    }

    var iconColor: LinearGradient {
        switch self {
        case .sendInvite:
            return LinearGradient(colors: [Color.couplyGoldenHour, Color(hex: "FFD700")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .enterCode:
            return LinearGradient(colors: [Color(hex: "A78BFA"), Color(hex: "8B5CF6")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var title: String {
        switch self {
        case .sendInvite: return "Send an invite"
        case .enterCode: return "Enter a code"
        }
    }

    var description: String {
        switch self {
        case .sendInvite: return "Share a code with your partner to connect"
        case .enterCode: return "Your partner already shared a code with you"
        }
    }
}

// MARK: - Pairing Option Card
struct PairingOptionCard: View {
    let option: PairingOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            CouplyHaptics.selection()
            onTap()
        }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(option.iconColor)
                        .frame(width: 44, height: 44)

                    Text(option.icon)
                        .font(.system(size: 20))
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.couplyDarkWarm)

                    Text(option.description)
                        .font(.system(size: 13))
                        .foregroundColor(.couplyWarmGray)
                }

                Spacer()

                // Selection indicator
                Circle()
                    .fill(isSelected ? Color.couplyCoral : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.couplyCoral : Color.couplyPeach, lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.couplyCoral : Color.couplyPeach, lineWidth: 2)
            )
            .shadow(color: isSelected ? Color.couplyCoral.opacity(0.15) : Color.clear, radius: 8, y: 4)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Waiting For Partner View
struct WaitingForPartnerView: View {
    let inviteCode: String?
    let onCancel: () -> Void

    @State private var copied = false

    var body: some View {
        VStack(spacing: 24) {
            // Invite code box
            VStack(spacing: 16) {
                Text("Your unique code")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))

                Text(inviteCode ?? "----")
                    .font(.custom("Fraunces", size: 32))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .tracking(4)

                Button {
                    UIPasteboard.general.string = inviteCode
                    copied = true
                    CouplyHaptics.success()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy Code")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color.couplyPrimaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.couplyCoral.opacity(0.4), radius: 20)
            .padding(.horizontal, 24)

            // Share buttons
            HStack(spacing: 16) {
                ShareButton(icon: "message.fill", color: Color(hex: "34C759"), label: "iMessage") {
                    shareVia(.message)
                }

                ShareButton(icon: "square.and.arrow.up", color: Color.couplyWarmGray, label: "More") {
                    shareVia(.other)
                }
            }

            // Waiting status
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.couplyCoral)
                            .frame(width: 10, height: 10)
                            .modifier(BounceModifier(delay: Double(index) * 0.2))
                    }
                }

                Text("Waiting for your partner to join...")
                    .font(.system(size: 15))
                    .foregroundColor(.couplyWarmGray)
            }
            .padding(20)
            .background(Color.couplyPeachLight)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            Spacer()

            // Cancel button
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.couplyWarmGray)
            }
            .padding(.bottom, 40)
        }
    }

    private func shareVia(_ method: ShareMethod) {
        guard let code = inviteCode else { return }
        let message = "Join me on Couply! Use my invite code: \(code)\n\nDownload: https://couply.app"

        switch method {
        case .message:
            // Open Messages with pre-filled text
            if let url = URL(string: "sms:&body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                UIApplication.shared.open(url)
            }
        case .other:
            // Use system share sheet
            let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }

    enum ShareMethod {
        case message, other
    }
}

struct ShareButton: View {
    let icon: String
    let color: Color
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.couplyWarmGray)
            }
        }
    }
}

struct BounceModifier: ViewModifier {
    let delay: Double
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = -8
                }
            }
    }
}

// MARK: - Enter Code View
struct EnterCodeView: View {
    @Binding var code: String
    let isLoading: Bool
    let error: String?
    let onSubmit: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Code input
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter invite code")
                    .font(.system(size: 14))
                    .foregroundColor(.couplyWarmGray)

                TextField("LOVE-XXXX", text: $code)
                    .font(.custom("Fraunces", size: 24))
                    .textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .background(Color.couplyPeachLight)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(error != nil ? Color.couplyError : Color.couplyPeach, lineWidth: 2)
                    )
                    .onChange(of: code) { _, newValue in
                        code = newValue.uppercased()
                    }
            }
            .padding(.horizontal, 24)

            if let error = error {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.couplyError)
                    .padding(.horizontal, 24)
            }

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button {
                    CouplyHaptics.medium()
                    onSubmit()
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Connect")
                    }
                }
                .buttonStyle(.couplyPrimary(disabled: code.count < 9))
                .disabled(code.count < 9 || isLoading)

                Button {
                    onBack()
                } label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.couplyWarmGray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - View Model
@MainActor
class PairingViewModel: ObservableObject {
    @Published var inviteCode: String?
    @Published var enteredCode = ""
    @Published var isWaitingForPartner = false
    @Published var showCodeEntry = false
    @Published var isLoading = false
    @Published var error: String?

    private let pairingService = PairingService.shared

    init() {
        // Listen for partner connection
        NotificationCenter.default.addObserver(
            forName: .partnerConnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isWaitingForPartner = false
        }
    }

    func generateInviteCode() async {
        isLoading = true
        error = nil

        do {
            let invite = try await pairingService.generateInviteCode()
            inviteCode = invite.code
            isWaitingForPartner = true
            CouplyHaptics.success()
        } catch {
            self.error = error.localizedDescription
            CouplyHaptics.error()
        }

        isLoading = false
    }

    func joinWithCode() async {
        isLoading = true
        error = nil

        do {
            try await pairingService.joinWithCode(enteredCode)
            CouplyHaptics.success()
        } catch {
            self.error = error.localizedDescription
            CouplyHaptics.error()
        }

        isLoading = false
    }

    func cancelWaiting() {
        pairingService.cancelWaiting()
        isWaitingForPartner = false
        inviteCode = nil
    }
}

#Preview {
    PairingView()
}

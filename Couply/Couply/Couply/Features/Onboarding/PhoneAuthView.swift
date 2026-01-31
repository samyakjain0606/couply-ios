import SwiftUI
import Combine

struct PhoneAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PhoneAuthViewModel()

    var body: some View {
        ZStack {
            Color.couplyWarmWhite
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.isVerifying ? "Enter the code" : "Your phone number")
                        .font(.custom("Fraunces", size: 28))
                        .fontWeight(.semibold)
                        .foregroundColor(.couplyDarkWarm)

                    Text(viewModel.isVerifying
                         ? "We sent a 4-digit code to \(viewModel.formattedPhoneNumber)"
                         : "We'll send you a code to verify it's really you")
                        .font(.system(size: 15))
                        .foregroundColor(.couplyWarmGray)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer().frame(height: 40)

                if viewModel.isVerifying {
                    // OTP Input
                    OTPInputView(code: $viewModel.otpCode, isLoading: viewModel.isLoading)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 24)

                    // Resend code
                    if viewModel.canResend {
                        Button {
                            Task {
                                await viewModel.resendCode()
                            }
                        } label: {
                            Text("Resend code")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.couplyCoralDeep)
                        }
                    } else {
                        Text("Resend code in \(viewModel.resendCountdown)s")
                            .font(.system(size: 15))
                            .foregroundColor(.couplyWarmGray)
                    }
                } else {
                    // Phone Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Phone Number")
                            .font(.system(size: 14))
                            .foregroundColor(.couplyWarmGray)

                        HStack(spacing: 12) {
                            // Country code
                            Menu {
                                ForEach(CountryCode.common, id: \.code) { country in
                                    Button {
                                        viewModel.selectedCountry = country
                                    } label: {
                                        Text("\(country.flag) \(country.name) (\(country.code))")
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(viewModel.selectedCountry.flag)
                                    Text(viewModel.selectedCountry.code)
                                        .foregroundColor(.couplyDarkWarm)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.couplyWarmGray)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 16)
                                .background(Color.couplyPeachLight)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.couplyPeach, lineWidth: 2)
                                )
                            }

                            // Phone number field
                            TextField("(555) 000-0000", text: $viewModel.phoneNumber)
                                .keyboardType(.phonePad)
                                .font(.system(size: 17))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.couplyPeachLight)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            viewModel.isPhoneValid ? Color.couplyPeach : Color.couplyPeach,
                                            lineWidth: 2
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Error message
                if let error = viewModel.error {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.couplyError)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.couplyError)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                // Continue button
                Button {
                    CouplyHaptics.medium()
                    Task {
                        if viewModel.isVerifying {
                            await viewModel.verifyCode()
                        } else {
                            await viewModel.sendVerificationCode()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(viewModel.isVerifying ? "Verify" : "Send Code")
                    }
                }
                .buttonStyle(.couplyPrimary(disabled: !viewModel.canContinue))
                .disabled(!viewModel.canContinue || viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Terms
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.system(size: 12))
                    .foregroundColor(.couplyWarmGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)

                // Progress dots
                ProgressDotsView(currentStep: 1, totalSteps: 4)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if viewModel.isVerifying {
                        viewModel.isVerifying = false
                        viewModel.otpCode = ""
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.couplyDarkWarm)
                        .frame(width: 40, height: 40)
                        .background(Color.couplyPeachLight)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - OTP Input View
struct OTPInputView: View {
    @Binding var code: String
    let isLoading: Bool
    @FocusState private var isFocused: Bool

    private let codeLength = 4

    var body: some View {
        ZStack {
            // Hidden text field for input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0)
                .onChange(of: code) { _, newValue in
                    // Limit to 4 digits
                    if newValue.count > codeLength {
                        code = String(newValue.prefix(codeLength))
                    }
                    // Auto-verify when complete
                    if newValue.count == codeLength {
                        CouplyHaptics.light()
                    }
                }

            // Visual OTP boxes
            HStack(spacing: 12) {
                ForEach(0..<codeLength, id: \.self) { index in
                    OTPDigitBox(
                        digit: digitAt(index),
                        isCurrent: index == code.count && isFocused,
                        isFilled: index < code.count
                    )
                }
            }
            .onTapGesture {
                isFocused = true
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    private func digitAt(_ index: Int) -> String {
        guard index < code.count else { return "" }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}

struct OTPDigitBox: View {
    let digit: String
    let isCurrent: Bool
    let isFilled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isFilled ? Color.couplyPeachLight : Color.couplyPeachLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isCurrent ? Color.couplyCoral : (isFilled ? Color.couplyCoral : Color.couplyPeach),
                            lineWidth: 2
                        )
                )
                .frame(width: 56, height: 64)

            Text(digit)
                .font(.custom("Fraunces", size: 28))
                .fontWeight(.semibold)
                .foregroundColor(.couplyDarkWarm)

            // Cursor
            if isCurrent {
                Rectangle()
                    .fill(Color.couplyCoral)
                    .frame(width: 2, height: 24)
                    .opacity(isCurrent ? 1 : 0)
                    .modifier(BlinkingModifier())
            }
        }
    }
}

struct BlinkingModifier: ViewModifier {
    @State private var isVisible = true

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
}

// MARK: - View Model
@MainActor
class PhoneAuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var selectedCountry = CountryCode.us
    @Published var otpCode = ""
    @Published var isVerifying = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var resendCountdown = 45
    @Published var canResend = false

    private var verificationID: String?
    private var resendTimer: Timer?

    var formattedPhoneNumber: String {
        "\(selectedCountry.code) \(phoneNumber)"
    }

    var fullPhoneNumber: String {
        selectedCountry.code + phoneNumber.filter { $0.isNumber }
    }

    var isPhoneValid: Bool {
        phoneNumber.filter { $0.isNumber }.count >= 10
    }

    var canContinue: Bool {
        if isVerifying {
            return otpCode.count == 4 && !isLoading
        } else {
            return isPhoneValid && !isLoading
        }
    }

    func sendVerificationCode() async {
        isLoading = true
        error = nil

        do {
            verificationID = try await AuthService.shared.sendVerificationCode(to: fullPhoneNumber)
            isVerifying = true
            startResendTimer()
            CouplyHaptics.success()
        } catch {
            self.error = error.localizedDescription
            CouplyHaptics.error()
        }

        isLoading = false
    }

    func verifyCode() async {
        guard let verificationID = verificationID else {
            error = "Please request a new code"
            return
        }

        isLoading = true
        error = nil

        do {
            try await AuthService.shared.verifyCode(otpCode, verificationID: verificationID)
            CouplyHaptics.success()
        } catch {
            self.error = error.localizedDescription
            otpCode = ""
            CouplyHaptics.error()
        }

        isLoading = false
    }

    func resendCode() async {
        canResend = false
        await sendVerificationCode()
    }

    private func startResendTimer() {
        resendCountdown = 45
        canResend = false

        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }

                if self.resendCountdown > 0 {
                    self.resendCountdown -= 1
                } else {
                    self.canResend = true
                    timer.invalidate()
                }
            }
        }
    }
}

// MARK: - Country Codes
struct CountryCode: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String

    static let us = CountryCode(name: "United States", code: "+1", flag: "🇺🇸")
    static let uk = CountryCode(name: "United Kingdom", code: "+44", flag: "🇬🇧")
    static let india = CountryCode(name: "India", code: "+91", flag: "🇮🇳")
    static let canada = CountryCode(name: "Canada", code: "+1", flag: "🇨🇦")
    static let australia = CountryCode(name: "Australia", code: "+61", flag: "🇦🇺")

    static let common: [CountryCode] = [us, uk, india, canada, australia]
}

#Preview {
    NavigationStack {
        PhoneAuthView()
    }
}

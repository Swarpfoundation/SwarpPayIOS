import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: SWARPSpacing.xl) {
            Spacer()
            LogoMark(size: 132)
            VStack(spacing: 10) {
                Text("SwarpPay")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SWARPColor.cream)
                Text("Digital vouchers and prepaid products for everyday access.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SWARPColor.coolGray)
            }
            Spacer()
            VStack(spacing: SWARPSpacing.sm) {
                PrimaryButton(title: "Get started") { appState.startConsumerFlow() }
                SecondaryButton(title: "Sign in") { appState.path.append(AppRoute.login) }
            }
            DebugBuildLabel()
        }
        .padding(SWARPSpacing.lg)
        .appBackground()
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScreenScaffold(title: "Digital vouchers for everyday access", subtitle: "Buy gaming, streaming, telecom, retail, and utility vouchers from one secure app.") {
            VStack(spacing: SWARPSpacing.md) {
                InfoCard {
                    Text("Built for Morocco")
                        .font(.headline)
                        .foregroundStyle(SWARPColor.cream)
                    Text("A prepaid catalog designed for local consumers, resellers, and safe app handoff.")
                        .foregroundStyle(SWARPColor.coolGray)
                }
                InfoCard {
                    Text("Receipts and support included")
                        .font(.headline)
                        .foregroundStyle(SWARPColor.cream)
                    Text("Track orders, view receipts, and contact support when you need help.")
                        .foregroundStyle(SWARPColor.coolGray)
                }
                InfoCard {
                    Text("Simple prepaid checkout")
                        .font(.headline)
                        .foregroundStyle(SWARPColor.cream)
                    Text("See delivery, verification, and total price before confirming a purchase.")
                        .foregroundStyle(SWARPColor.coolGray)
                }
                PrimaryButton(title: "Sign in") { appState.path.append(AppRoute.login) }
                SecondaryButton(title: "Create account") { appState.path.append(AppRoute.register) }
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email = ""
    @State private var passcode = ""

    var body: some View {
        ScreenScaffold(title: "Sign in", subtitle: "Sign in to manage your vouchers, receipts, and support requests.") {
            VStack(spacing: SWARPSpacing.md) {
                DemoTextField(title: "Email", text: $email)
                DemoTextField(title: "Password", text: $passcode, secure: true)
                #if DEBUG
                if AppEnvironment.current.features.demoAuthEnabled {
                    PrimaryButton(title: "Continue in internal demo") { appState.completeDemoAuth() }
                } else {
                    FeatureUnavailableCard(
                        title: "Sign in is unavailable",
                        message: "SwarpPay authentication requires a production backend and is disabled in this build. No local session has been created."
                    )
                }
                #else
                FeatureUnavailableCard(
                    title: "Sign in is unavailable",
                    message: "SwarpPay authentication requires a production backend and is disabled in this build. No local session has been created."
                )
                #endif
                SecondaryButton(title: "Create account") { appState.path.append(AppRoute.register) }
                Button("Forgot password?") { }
                    .font(SWARPType.detail.weight(.semibold))
                    .foregroundStyle(SWARPColor.signal)
            }
        }
    }
}

struct RegisterView: View {
    @EnvironmentObject private var appState: AppState
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        ScreenScaffold(title: "Create account", subtitle: "Set up your SwarpPay profile to browse vouchers, track orders, and keep receipts in one place.") {
            VStack(spacing: SWARPSpacing.md) {
                DemoTextField(title: "Full name", text: $name)
                DemoTextField(title: "Email", text: $email)
                #if DEBUG
                if AppEnvironment.current.features.demoAuthEnabled {
                    PrimaryButton(title: "Create internal demo account") { appState.completeDemoAuth() }
                } else {
                    FeatureUnavailableCard(
                        title: "Account creation is unavailable",
                        message: "Account creation requires a production backend and is disabled in this build. No local user or KYC state has been created."
                    )
                }
                #else
                FeatureUnavailableCard(
                    title: "Account creation is unavailable",
                    message: "Account creation requires a production backend and is disabled in this build. No local user or KYC state has been created."
                )
                #endif
                SecondaryButton(title: "I already have an account") { appState.path.append(AppRoute.login) }
            }
        }
    }
}

struct DemoTextField: View {
    let title: String
    @Binding var text: String
    var secure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SWARPColor.coolGray)
            Group {
                if secure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .padding()
            .foregroundStyle(SWARPColor.cream)
            .background(SWARPColor.navyLift.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: SWARPRadius.md))
        }
    }
}

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    private let accentGreen = Color.green

    var body: some View {
        ZStack {
            // Adaptive background
            backgroundGradient
                .ignoresSafeArea()

            TabView(selection: $viewModel.currentPage) {
                welcomePage.tag(0)
                howItWorksPage.tag(1)
                setupPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)

            // Skip button (top-right) + custom page indicator (bottom)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation { viewModel.currentPage = 2 }
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                }
                Spacer()

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        if index == viewModel.currentPage {
                            Capsule()
                                .fill(accentGreen)
                                .frame(width: 28, height: 8)
                        } else {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.currentPage)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.08, blue: 0.04),
                Color(red: 0.06, green: 0.14, blue: 0.08),
                Color(red: 0.04, green: 0.10, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            // Glowing ring behind the icon
            ZStack {
                Circle()
                    .fill(accentGreen.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [accentGreen.opacity(0.6), accentGreen.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 150, height: 150)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 80))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(accentGreen)
                    .scaleEffect(viewModel.animateSymbol ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: viewModel.animateSymbol
                    )
            }

            VStack(spacing: 12) {
                Text("HarvestGain")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Farm-to-Muscle Ecosystem")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(accentGreen.opacity(0.9))
                    .textCase(.uppercase)
                    .tracking(2)
            }

            // Tagline card
            Text("Turn your garden into\nyour fitness pharmacy")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(accentGreen.opacity(0.2), lineWidth: 1)
                        )
                )

            Spacer()

            // Swipe hint
            HStack(spacing: 6) {
                Text("Swipe to continue")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.45))
                Image(systemName: "chevron.right.2")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(.bottom, 60)
        }
        .padding()
        .onAppear { viewModel.animateSymbol = true }
    }

    // MARK: - Page 2: How It Works

    private var howItWorksPage: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("How It Works")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Three simple steps to fuel your fitness\nwith fresh, home-grown nutrition.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(spacing: 16) {
                stepRow(
                    icon: "target",
                    color: .orange,
                    title: "Set Your Goal",
                    description: "Choose bulking or cutting — we tailor your garden plan accordingly."
                )
                stepRow(
                    icon: "leaf.arrow.circlepath",
                    color: accentGreen,
                    title: "Smart Planting",
                    description: "Get crop suggestions matched to your macro & micronutrient needs."
                )
                stepRow(
                    icon: "heart.text.square.fill",
                    color: .pink,
                    title: "Live Sync via HealthKit",
                    description: "Workouts and body metrics auto-adjust your harvest priorities."
                )
            }
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private func stepRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - Page 3: Setup

    private var setupPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Personalize")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Tell us about yourself and set your\nfitness direction to get started.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            // Personal Details Card
            VStack(alignment: .leading, spacing: 16) {
                Label("About You", systemImage: "person.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(accentGreen)
                            .frame(width: 20)
                        TextField("Your Name", text: $viewModel.draftName)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(accentGreen.opacity(viewModel.draftName.isEmpty ? 0.15 : 0.4), lineWidth: 1)
                            )
                    )

                    HStack(spacing: 12) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(accentGreen)
                            .frame(width: 20)
                        TextField("Your Profession (optional)", text: $viewModel.draftProfession)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)

            // Goal Picker
            VStack(alignment: .leading, spacing: 12) {
                Label("Primary Goal", systemImage: "flame.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))

                Picker("Fitness Goal", selection: $viewModel.selectedGoal) {
                    ForEach(FitnessGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .pickerStyle(.segmented)

                // Goal detail card
                HStack(spacing: 12) {
                    Image(systemName: viewModel.selectedGoal.icon)
                        .font(.title2)
                        .foregroundColor(accentGreen)
                    Text(viewModel.selectedGoal.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accentGreen.opacity(0.08))
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)

            // Health Authorization Button
            Button(action: viewModel.authorizeHealth) {
                HStack(spacing: 10) {
                    Image(systemName: viewModel.healthAuthorized ? "checkmark.circle.fill" : "heart.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(viewModel.healthAuthorized ? .green : .pink)

                    Text(viewModel.healthAuthorized ? "Apple Health Connected" : "Connect Apple Health")
                        .fontWeight(.semibold)

                    Spacer()

                    if !viewModel.healthAuthorized {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(
                                    viewModel.healthAuthorized ? accentGreen.opacity(0.3) : .white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                )
                .foregroundColor(.white)
            }
            .padding(.horizontal, 20)

            Spacer()

            // Get Started Button
            Button(action: viewModel.completeOnboarding) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(viewModel.canProceed ? .black : .white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                viewModel.canProceed
                                ? LinearGradient(
                                    colors: [accentGreen, Color(red: 0.2, green: 0.8, blue: 0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [.white.opacity(0.1), .white.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: viewModel.canProceed ? accentGreen.opacity(0.4) : .clear, radius: 12, y: 6)
                    )
            }
            .disabled(!viewModel.canProceed)
            .animation(.easeInOut(duration: 0.25), value: viewModel.canProceed)
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
        .padding()
    }
}

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            MainView()
        } else {
            OnboardingView()
        }
    }
}

// MARK: - Main View (Post-Onboarding)

struct MainView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.04),
                        Color(red: 0.06, green: 0.14, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.green)

                    Text("Welcome to HarvestGain")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Your Farm-to-Muscle journey starts here.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

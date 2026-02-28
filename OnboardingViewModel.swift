import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("fitnessGoal") var storedGoal: String = FitnessGoal.bulking.rawValue
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userProfession") var userProfession: String = ""

    @Published var currentPage = 0
    @Published var selectedGoal: FitnessGoal = .bulking
    @Published var healthAuthorized = false
    @Published var animateSymbol = false

    // Draft fields for the setup form
    @Published var draftName = ""
    @Published var draftProfession = ""

    /// Requires at least a name before proceeding.
    var canProceed: Bool {
        !draftName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    func authorizeHealth() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            healthAuthorized = true
        }
    }

    func completeOnboarding() {
        guard canProceed else { return }
        userName = draftName.trimmingCharacters(in: .whitespaces)
        userProfession = draftProfession.trimmingCharacters(in: .whitespaces)
        storedGoal = selectedGoal.rawValue
        withAnimation(.easeInOut(duration: 0.4)) {
            hasCompletedOnboarding = true
        }
    }
}

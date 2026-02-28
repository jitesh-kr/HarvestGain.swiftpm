import Foundation
import HealthKit

/// Workout summary returned after fetching the most recent session.
struct WorkoutSummary: Sendable {
    let durationMinutes: Double
    let caloriesBurned: Double
}

@MainActor
final class HealthSyncManager: ObservableObject {

    // MARK: - Published State

    @Published var heavyWorkoutDetected = false
    @Published var isRecoveryMode = false
    @Published var latestWorkout: WorkoutSummary?

    private let healthStore = HKHealthStore()

    // MARK: - Authorization

    /// Requests read-only access to workout and active energy data.
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToRead: Set<HKObjectType> = [
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch & Detect

    /// Fetches the most recent workout from the last 24 hours.
    /// Sets `isRecoveryMode` if any workout is found, and flags heavy
    /// strength-training sessions (> 45 min) via `heavyWorkoutDetected`.
    func fetchRecentWorkouts() async {
        let workoutType = HKWorkoutType.workoutType()

        let now = Date()
        let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(
            withStart: oneDayAgo,
            end: now,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                defer { continuation.resume() }

                if let error {
                    print("Workout fetch error: \(error.localizedDescription)")
                    return
                }

                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else { return }

                // Most recent workout → summary
                let most = workouts[0]
                let durationMin = most.duration / 60.0
                let calories = most.totalEnergyBurned?
                    .doubleValue(for: .kilocalorie()) ?? 0

                let foundHeavy = workouts.contains { w in
                    w.workoutActivityType == .traditionalStrengthTraining
                    && w.duration > 45 * 60
                }

                Task { @MainActor [weak self] in
                    self?.latestWorkout = WorkoutSummary(
                        durationMinutes: durationMin,
                        caloriesBurned: calories
                    )
                    self?.isRecoveryMode = true
                    if foundHeavy {
                        self?.heavyWorkoutDetected = true
                    }
                }
            }

            healthStore.execute(query)
        }
    }
}

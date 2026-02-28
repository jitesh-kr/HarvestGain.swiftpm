import SwiftUI

// MARK: - Fitness Goal

enum FitnessGoal: String, CaseIterable, Identifiable, Sendable {
    case bulking = "Bulking"
    case cutting = "Cutting"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bulking: return "figure.strengthtraining.traditional"
        case .cutting: return "figure.run"
        }
    }

    var subtitle: String {
        switch self {
        case .bulking: return "Build muscle with nutrient-dense crops"
        case .cutting: return "Lean out with low-calorie superfoods"
        }
    }
}

// MARK: - Crop Yield (Chart Data)

struct CropYield: Identifiable, Sendable {
    let id = UUID()
    let cropName: String
    let day: String
    let proteinGrams: Double
    let unit: String        // e.g. "mg", "mcg", "%"
}

// MARK: - Harvest Alert

struct HarvestAlert: Identifiable, Sendable {
    let id = UUID()
    let cropName: String
    let message: String
    var isActive: Bool
}

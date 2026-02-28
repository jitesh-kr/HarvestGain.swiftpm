import Foundation
import SwiftData

@Model
final class Crop {
    var id: UUID
    var name: String
    var plantDate: Date
    var targetNutrient: String
    var daysToPeak: Int
    var customBaseValue: Double?
    var customUnit: String?

    /// Returns a value from 0.0 to 1.0 representing how far along the crop
    /// is toward its peak nutrient yield, clamped so it never exceeds 1.0.
    var currentYieldPercentage: Double {
        let elapsed = Date().timeIntervalSince(plantDate)
        let total = Double(daysToPeak) * 86_400 // seconds per day
        guard total > 0 else { return 0 }
        return min(elapsed / total, 1.0)
    }

    init(
        id: UUID = UUID(),
        name: String,
        plantDate: Date,
        targetNutrient: String,
        daysToPeak: Int,
        customBaseValue: Double? = nil,
        customUnit: String? = nil
    ) {
        self.id = id
        self.name = name
        self.plantDate = plantDate
        self.targetNutrient = targetNutrient
        self.daysToPeak = daysToPeak
        self.customBaseValue = customBaseValue
        self.customUnit = customUnit
    }
}

// MARK: - Sample Data

extension Crop {
    @MainActor
    static let sampleCrops: [Crop] = [
        Crop(
            name: "Spinach",
            plantDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            targetNutrient: "Nitrates",
            daysToPeak: 30
        ),
        Crop(
            name: "Soybeans",
            plantDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
            targetNutrient: "Protein",
            daysToPeak: 60
        ),
        Crop(
            name: "Beets",
            plantDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            targetNutrient: "Endurance",
            daysToPeak: 45
        )
    ]
}

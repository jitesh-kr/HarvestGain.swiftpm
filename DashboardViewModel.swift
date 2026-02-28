import SwiftUI

// MARK: - Fitness-Goal Category

enum CropCategory: String {
    case bulking   // high protein / calorie crops
    case cutting   // high fiber / nitrate / low calorie crops
}

// MARK: - USDA Nutrient Reference

/// Represents a USDA-style base nutrient value per 100 g of raw crop yield.
private struct NutrientInfo {
    let baseValue: Double       // amount per 100 g
    let unit: String            // "mg", "mcg", "g", etc.
    let category: CropCategory  // bulking or cutting
}

/// A single crop suggestion shown in the Smart Suggestion sheet.
struct SuggestedCrop: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let primaryNutrient: String
    let daysToPeak: Int
}

/// Emoji icons keyed by lowercase crop name.
let cropIcons: [String: String] = [
    // Bulking
    "soybeans": "🫘", "edamame": "🫛", "lentils": "🫘", "chickpeas": "🫘",
    "quinoa": "🌾", "peanuts": "🥜", "sunflower seeds": "🌻", "pumpkin seeds": "🎃",
    "fava beans": "🫘", "black beans": "🫘", "kidney beans": "🫘", "peas": "🫛",
    "chia seeds": "🌱", "flax seeds": "🌾", "oats": "🥣", "buckwheat": "🌾",
    "potatoes": "🥔", "sweet potatoes": "🍠", "corn": "🌽", "brown rice": "🍚",
    "spelt": "🌾", "amaranth": "🌾", "lima beans": "🫘", "mung beans": "🫘",
    "spirulina": "🦠", "hemp seeds": "🌿",
    // Cutting
    "spinach": "🥬", "kale": "🥬", "broccoli": "🥦", "arugula": "🌿",
    "beetroot": "🍠", "swiss chard": "🥬", "asparagus": "🎋", "celery": "🌿",
    "cucumber": "🥒", "zucchini": "🥒", "bell peppers": "🫑", "cauliflower": "🥦",
    "cabbage": "🥬", "bok choy": "🥬", "watercress": "🌿", "radish": "🧅",
    "green beans": "🫛", "brussels sprouts": "🥬", "lettuce": "🥬", "mushrooms": "🍄",
    "tomatoes": "🍅", "carrots": "🥕", "blueberries": "🫐", "raspberries": "🍓",
    "strawberries": "🍓"
]

/// Returns the emoji icon for a crop name (case-insensitive). Falls back to 🌱.
func cropIcon(for name: String) -> String {
    cropIcons[name.lowercased()] ?? "🌱"
}

/// Returns true if the crop name exists in the built-in nutrient library.
func isCropInLibrary(_ name: String) -> Bool {
    nutrientLibrary[name.lowercased()] != nil
}

/// Returns a human-friendly nutrient label for a crop category.
private func primaryNutrientLabel(for category: CropCategory, unit: String) -> String {
    switch category {
    case .bulking:
        return "High Protein"
    case .cutting:
        switch unit {
        case "mcg": return "Vitamin A Rich"
        default:    return "Nitrate Rich"
        }
    }
}

/// 50+ crop library — USDA FoodData Central approximations.
private let nutrientLibrary: [String: NutrientInfo] = [

    // ═══════════════════════════════════════════
    //  BULKING — High Protein / Calorie Crops
    // ═══════════════════════════════════════════

    "soybeans":        NutrientInfo(baseValue: 36.5,  unit: "g",  category: .bulking),   // Protein
    "edamame":         NutrientInfo(baseValue: 11.9,  unit: "g",  category: .bulking),   // Protein
    "lentils":         NutrientInfo(baseValue: 25.8,  unit: "g",  category: .bulking),   // Protein
    "chickpeas":       NutrientInfo(baseValue: 20.5,  unit: "g",  category: .bulking),   // Protein
    "quinoa":          NutrientInfo(baseValue: 14.1,  unit: "g",  category: .bulking),   // Protein
    "peanuts":         NutrientInfo(baseValue: 25.8,  unit: "g",  category: .bulking),   // Protein
    "sunflower seeds": NutrientInfo(baseValue: 20.8,  unit: "g",  category: .bulking),   // Protein
    "pumpkin seeds":   NutrientInfo(baseValue: 30.2,  unit: "g",  category: .bulking),   // Protein
    "fava beans":      NutrientInfo(baseValue: 26.1,  unit: "g",  category: .bulking),   // Protein
    "black beans":     NutrientInfo(baseValue: 21.6,  unit: "g",  category: .bulking),   // Protein
    "kidney beans":    NutrientInfo(baseValue: 22.5,  unit: "g",  category: .bulking),   // Protein
    "peas":            NutrientInfo(baseValue: 5.4,   unit: "g",  category: .bulking),   // Protein
    "chia seeds":      NutrientInfo(baseValue: 16.5,  unit: "g",  category: .bulking),   // Protein
    "flax seeds":      NutrientInfo(baseValue: 18.3,  unit: "g",  category: .bulking),   // Protein
    "oats":            NutrientInfo(baseValue: 16.9,  unit: "g",  category: .bulking),   // Protein
    "buckwheat":       NutrientInfo(baseValue: 13.3,  unit: "g",  category: .bulking),   // Protein
    "potatoes":        NutrientInfo(baseValue: 2.1,   unit: "g",  category: .bulking),   // Protein (high cal)
    "sweet potatoes":  NutrientInfo(baseValue: 1.6,   unit: "g",  category: .bulking),   // Protein (high cal)
    "corn":            NutrientInfo(baseValue: 3.4,   unit: "g",  category: .bulking),   // Protein
    "brown rice":      NutrientInfo(baseValue: 7.9,   unit: "g",  category: .bulking),   // Protein
    "spelt":           NutrientInfo(baseValue: 14.6,  unit: "g",  category: .bulking),   // Protein
    "amaranth":        NutrientInfo(baseValue: 13.6,  unit: "g",  category: .bulking),   // Protein
    "lima beans":      NutrientInfo(baseValue: 21.5,  unit: "g",  category: .bulking),   // Protein
    "mung beans":      NutrientInfo(baseValue: 23.9,  unit: "g",  category: .bulking),   // Protein
    "spirulina":       NutrientInfo(baseValue: 57.5,  unit: "g",  category: .bulking),   // Protein
    "hemp seeds":      NutrientInfo(baseValue: 31.6,  unit: "g",  category: .bulking),   // Protein

    // ═══════════════════════════════════════════
    //  CUTTING — High Fiber / Low Calorie Crops
    // ═══════════════════════════════════════════

    "spinach":         NutrientInfo(baseValue: 2.7,   unit: "mg", category: .cutting),   // Iron
    "kale":            NutrientInfo(baseValue: 93.4,  unit: "mg", category: .cutting),   // Vitamin C
    "broccoli":        NutrientInfo(baseValue: 89.2,  unit: "mg", category: .cutting),   // Vitamin C
    "arugula":         NutrientInfo(baseValue: 15.0,  unit: "mg", category: .cutting),   // Vitamin C
    "beetroot":        NutrientInfo(baseValue: 78.0,  unit: "mg", category: .cutting),   // Folate
    "swiss chard":     NutrientInfo(baseValue: 30.0,  unit: "mg", category: .cutting),   // Vitamin C
    "asparagus":       NutrientInfo(baseValue: 5.6,   unit: "mg", category: .cutting),   // Vitamin C
    "celery":          NutrientInfo(baseValue: 3.1,   unit: "mg", category: .cutting),   // Vitamin C
    "cucumber":        NutrientInfo(baseValue: 147,   unit: "mg", category: .cutting),   // Potassium
    "zucchini":        NutrientInfo(baseValue: 17.9,  unit: "mg", category: .cutting),   // Vitamin C
    "bell peppers":    NutrientInfo(baseValue: 127.7, unit: "mg", category: .cutting),   // Vitamin C
    "cauliflower":     NutrientInfo(baseValue: 48.2,  unit: "mg", category: .cutting),   // Vitamin C
    "cabbage":         NutrientInfo(baseValue: 36.6,  unit: "mg", category: .cutting),   // Vitamin C
    "bok choy":        NutrientInfo(baseValue: 45.0,  unit: "mg", category: .cutting),   // Vitamin C
    "watercress":      NutrientInfo(baseValue: 43.0,  unit: "mg", category: .cutting),   // Vitamin C
    "radish":          NutrientInfo(baseValue: 14.8,  unit: "mg", category: .cutting),   // Vitamin C
    "green beans":     NutrientInfo(baseValue: 12.2,  unit: "mg", category: .cutting),   // Vitamin C
    "brussels sprouts":NutrientInfo(baseValue: 85.0,  unit: "mg", category: .cutting),   // Vitamin C
    "lettuce":         NutrientInfo(baseValue: 7.4,   unit: "mg", category: .cutting),   // Vitamin C
    "mushrooms":       NutrientInfo(baseValue: 2.1,   unit: "mg", category: .cutting),   // Vitamin C
    "tomatoes":        NutrientInfo(baseValue: 237,   unit: "mg", category: .cutting),   // Potassium
    "carrots":         NutrientInfo(baseValue: 835,   unit: "mcg",category: .cutting),   // Vitamin A
    "blueberries":     NutrientInfo(baseValue: 9.7,   unit: "mg", category: .cutting),   // Vitamin C
    "raspberries":     NutrientInfo(baseValue: 26.2,  unit: "mg", category: .cutting),   // Vitamin C
    "strawberries":    NutrientInfo(baseValue: 58.8,  unit: "mg", category: .cutting),   // Vitamin C
]

// MARK: - Smart Suggestion Helpers

/// Top crop suggestions for each goal when the garden doesn't match.
private let bulkingSuggestions = ["Soybeans", "Lentils", "Chickpeas", "Quinoa", "Peanuts"]
private let cuttingSuggestions = ["Spinach", "Kale", "Broccoli", "Arugula", "Beetroot"]

// MARK: - View Model

@MainActor
final class DashboardViewModel: ObservableObject {
    @AppStorage("fitnessGoal") var storedGoal: String = FitnessGoal.bulking.rawValue
    @AppStorage("userName") var userName: String = ""

    @Published var harvestAlert: HarvestAlert?
    @Published var cropYields: [CropYield] = []
    @Published var harvestLogged = false

    /// The dominant unit displayed on the chart Y-axis (e.g. "mg", "mcg").
    @Published var chartUnit: String = "mg"

    // Recovery mode state
    @Published var isRecoveryMode = false
    @Published var latestWorkout: WorkoutSummary?
    @Published var recoveryCrop: Crop?

    // Smart Suggestion & Warnings
    @Published var smartSuggestion: String?
    @Published var targetMismatchAlert: String?

    // "Suggest Crops" sheet state
    @Published var suggestedCrops: [SuggestedCrop] = []
    @Published var showSuggestionSheet = false

    private let healthManager = HealthSyncManager()

    // MARK: - Computed

    var fitnessGoal: FitnessGoal {
        FitnessGoal(rawValue: storedGoal) ?? .bulking
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12:  timeOfDay = "Good Morning"
        case 12..<17: timeOfDay = "Good Afternoon"
        case 17..<22: timeOfDay = "Good Evening"
        default:      timeOfDay = "Good Night"
        }

        let name = userName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "\(timeOfDay)!" : "\(timeOfDay), \(name)!"
    }

    var subtitle: String {
        switch fitnessGoal {
        case .bulking: return "Fuel your gains with high-protein harvests."
        case .cutting: return "Stay lean with nutrient-dense garden greens."
        }
    }

    // MARK: - HealthKit Lifecycle

    func fetchHealthData() async {
        await healthManager.requestAuthorization()
        await healthManager.fetchRecentWorkouts()
        isRecoveryMode = healthManager.isRecoveryMode
        latestWorkout = healthManager.latestWorkout
        updateHarvestAlert()
    }

    private func updateHarvestAlert() {
        guard healthManager.heavyWorkoutDetected else { return }
        let crop = fitnessGoal == .bulking ? "Spinach" : "Kale"
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            harvestAlert = HarvestAlert(
                cropName: crop,
                message: "Heavy strength session detected! Your \(crop) is at peak nitrates. Harvest now for recovery.",
                isActive: true
            )
        }
    }

    // MARK: - Actions

    func logHarvest() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            healthManager.heavyWorkoutDetected = false
            harvestAlert = nil
            harvestLogged = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.harvestLogged = false }
        }
    }

    // MARK: - Recovery Harvest Detection

    /// High-nutrient crop names eligible for recovery harvest alerts.
    private let highNutrientCrops: Set<String> = [
        "spinach", "soybeans", "kale", "lentils", "edamame", "broccoli"
    ]

    /// Checks if Recovery Mode is active AND a high-nutrient crop is at >90% maturity.
    func checkRecoveryHarvest(from crops: [Crop]) {
        guard isRecoveryMode else {
            recoveryCrop = nil
            return
        }

        recoveryCrop = crops.first { crop in
            highNutrientCrops.contains(crop.name.lowercased())
            && crop.currentYieldPercentage > 0.9
        }
    }

    // MARK: - Smart Suggestion

    /// Checks whether the user's garden has crops matching their fitness goal.
    /// If not, populates `smartSuggestion` with a helpful recommendation.
    func evaluateSmartSuggestion(from crops: [Crop]) {
        let targetCategory: CropCategory = fitnessGoal == .bulking ? .bulking : .cutting

        let hasMatchingCrop = crops.contains { crop in
            if let info = nutrientLibrary[crop.name.lowercased()] {
                return info.category == targetCategory
            }
            return false
        }

        if hasMatchingCrop || crops.isEmpty {
            smartSuggestion = nil
        } else {
            let suggestions: [String]
            let goalName: String
            if fitnessGoal == .bulking {
                suggestions = bulkingSuggestions
                goalName = "Bulking"
            } else {
                suggestions = cuttingSuggestions
                goalName = "Cutting"
            }
            let picks = suggestions.prefix(2).joined(separator: " or ")
            smartSuggestion = "To hit your \(goalName) goal, consider planting \(picks)!"
        }
    }

    /// Picks 3 random crops from the nutrient library that match the user's fitness goal.
    func generateSuggestions() {
        let targetCategory: CropCategory = fitnessGoal == .bulking ? .bulking : .cutting
        let matching = nutrientLibrary.filter { $0.value.category == targetCategory }
        let picks = Array(matching.shuffled().prefix(3))

        suggestedCrops = picks.map { key, info in
            let displayName = key.capitalized
            let icon = cropIcons[key] ?? "🌱"
            let label = primaryNutrientLabel(for: info.category, unit: info.unit)
            let estimatedDays: Int
            switch info.category {
            case .bulking: estimatedDays = 60
            case .cutting: estimatedDays = 30
            }
            return SuggestedCrop(
                name: displayName,
                icon: icon,
                primaryNutrient: label,
                daysToPeak: estimatedDays
            )
        }
        showSuggestionSheet = true
    }

    // MARK: - Dynamic Chart Data (USDA Formula)

    /// Generates a 7-day projected nutrient yield using USDA reference values.
    ///
    /// **Goal filtering:** Only crops whose category matches the user's
    /// current `fitnessGoal` are shown in the chart. Unmatched crops are
    /// still tracked internally but hidden from the Growth-to-Gain chart.
    ///
    /// **Formula per day:**
    /// ```
    /// gain = (baseValue / daysToPeak) × (daysSincePlanting + daysIntoFuture)
    /// ```
    /// Capped at `baseValue` so yield never exceeds the crop's maximum.
    ///
    /// Falls back to a 0–100 % growth curve when the crop isn't in the library.
    func calculateWeeklyYield(from crops: [Crop]) {
        guard !crops.isEmpty else {
            cropYields = []
            return
        }

        let targetCategory: CropCategory = fitnessGoal == .bulking ? .bulking : .cutting
        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let calendar = Calendar.current
        let today = Date()
        var yields: [CropYield] = []
        var unitCounts: [String: Int] = [:]

        var mismatchedCount = 0

        for crop in crops {
            let info = nutrientLibrary[crop.name.lowercased()]

            // Goal filtering: prioritise matching crops.
            // Show crops that match the goal OR are unknown (fallback).
            if let info, info.category != targetCategory {
                mismatchedCount += 1
                continue
            }

            // Days elapsed since planting (floored to whole days).
            let daysSincePlanting = max(
                calendar.dateComponents([.day], from: crop.plantDate, to: today).day ?? 0,
                0
            )

            if let info {
                // USDA-backed calculation
                let dailyRate = crop.daysToPeak > 0
                    ? info.baseValue / Double(crop.daysToPeak)
                    : 0

                for (futureDay, label) in dayLabels.enumerated() {
                    let totalDays = Double(daysSincePlanting + futureDay)
                    let gain = min(dailyRate * totalDays, info.baseValue)
                    yields.append(
                        CropYield(cropName: crop.name, day: label,
                                  proteinGrams: gain, unit: info.unit)
                    )
                }
                unitCounts[info.unit, default: 0] += 1
            } else if let customBase = crop.customBaseValue, customBase > 0 {
                // User-provided base value for crops not in the library
                let unit = crop.customUnit ?? "g"
                let dailyRate = crop.daysToPeak > 0
                    ? customBase / Double(crop.daysToPeak)
                    : 0

                for (futureDay, label) in dayLabels.enumerated() {
                    let totalDays = Double(daysSincePlanting + futureDay)
                    let gain = min(dailyRate * totalDays, customBase)
                    yields.append(
                        CropYield(cropName: crop.name, day: label,
                                  proteinGrams: gain, unit: unit)
                    )
                }
                unitCounts[unit, default: 0] += 1
            } else {
                // Fallback: generic 0–100 % growth curve
                let dailyRate = crop.daysToPeak > 0
                    ? 100.0 / Double(crop.daysToPeak)
                    : 0

                for (futureDay, label) in dayLabels.enumerated() {
                    let totalDays = Double(daysSincePlanting + futureDay)
                    let pct = min(dailyRate * totalDays, 100.0)
                    yields.append(
                        CropYield(cropName: crop.name, day: label,
                                  proteinGrams: pct, unit: "%")
                    )
                }
                unitCounts["%", default: 0] += 1
            }
        }

        cropYields = yields

        // Update mismatch alert
        if mismatchedCount > 0 {
            let plural = mismatchedCount == 1 ? "crop is" : "crops are"
            let targetName = fitnessGoal == .bulking ? "Bulking" : "Cutting"
            let oppositeName = fitnessGoal == .bulking ? "Cutting" : "Bulking"
            targetMismatchAlert = "\(mismatchedCount) \(plural) hidden from the chart because they are better suited for \(oppositeName), but your current goal is \(targetName)."
        } else {
            targetMismatchAlert = nil
        }

        // Dominant unit wins for the Y-axis label
        chartUnit = unitCounts.max(by: { $0.value < $1.value })?.key ?? "mg"
    }
}

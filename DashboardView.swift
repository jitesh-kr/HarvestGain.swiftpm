import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DashboardViewModel()
    @Query private var crops: [Crop]

    private let accentGreen = Color.green

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        suggestCropsButton
                        recoveryBadge
                        smartSuggestionCard
                        harvestAlertSection
                        recoveryHarvestCard
                        targetMismatchCard
                        chartSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.fetchHealthData()
                viewModel.calculateWeeklyYield(from: crops)
                viewModel.checkRecoveryHarvest(from: crops)
                viewModel.evaluateSmartSuggestion(from: crops)
            }
            .onChange(of: crops) { _, newCrops in
                viewModel.calculateWeeklyYield(from: newCrops)
                viewModel.checkRecoveryHarvest(from: newCrops)
                viewModel.evaluateSmartSuggestion(from: newCrops)
            }
            .onChange(of: viewModel.storedGoal) { _, _ in
                viewModel.calculateWeeklyYield(from: crops)
                viewModel.evaluateSmartSuggestion(from: crops)
            }
            .sheet(isPresented: $viewModel.showSuggestionSheet) {
                CropSuggestionSheet(
                    suggestions: viewModel.suggestedCrops,
                    onPlant: { suggestion in
                        plantSuggestion(suggestion)
                        viewModel.showSuggestionSheet = false
                    }
                )
            }
        }
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(viewModel.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Phase badge
                HStack(spacing: 6) {
                    Image(systemName: viewModel.fitnessGoal.icon)
                        .font(.caption)
                    Text(viewModel.fitnessGoal.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(accentGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(accentGreen.opacity(0.15))
                        .overlay(
                            Capsule()
                                .strokeBorder(accentGreen.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(20)
        .background(lighterGlassCard)
    }

    // MARK: - Suggest Crops Button

    private var suggestCropsButton: some View {
        Button(action: { viewModel.generateSuggestions() }) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.body.weight(.semibold))
                Text("Suggest Crops")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.teal, Color(red: 0.2, green: 0.85, blue: 0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: .teal.opacity(0.3), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Plant Now Action

    private func plantSuggestion(_ suggestion: SuggestedCrop) {
        let crop = Crop(
            name: suggestion.name,
            plantDate: Date(),
            targetNutrient: suggestion.primaryNutrient,
            daysToPeak: suggestion.daysToPeak
        )
        modelContext.insert(crop)
    }

    // MARK: - Smart Suggestion Card

    @ViewBuilder
    private var smartSuggestionCard: some View {
        if let suggestion = viewModel.smartSuggestion {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "lightbulb.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.teal)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Suggestion")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.teal.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.teal.opacity(0.25), lineWidth: 1)
                    )
            )
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }

    // MARK: - Recovery Mode Badge

    @ViewBuilder
    private var recoveryBadge: some View {
        if viewModel.isRecoveryMode {
            HStack(spacing: 10) {
                Image(systemName: "bolt.heart.fill")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Recovery Mode Active")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)

                    if let w = viewModel.latestWorkout {
                        Text("\(Int(w.durationMinutes)) min · \(Int(w.caloriesBurned)) kcal burned")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Spacer()

                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.orange.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.orange.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.orange.opacity(0.25), lineWidth: 1)
                    )
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Harvest for Recovery Card

    @ViewBuilder
    private var recoveryHarvestCard: some View {
        if let crop = viewModel.recoveryCrop {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "leaf.arrow.circlepath")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.orange)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Harvest for Recovery")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("High Priority")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    Text("\(Int(crop.currentYieldPercentage * 100))%")
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(.green)
                }

                Text("Your **\(crop.name)** is at peak maturity! Harvest now to maximize post-workout recovery nutrients.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: viewModel.logHarvest) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Harvest \(crop.name) Now")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [.orange, Color(red: 1.0, green: 0.7, blue: 0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
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
                            .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .orange.opacity(0.15), radius: 16, y: 8)
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
        }
    }

    // MARK: - Harvest Alert

    @ViewBuilder
    private var harvestAlertSection: some View {
        if let alert = viewModel.harvestAlert {
            VStack(alignment: .leading, spacing: 14) {
                // Header row
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(accentGreen.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "bolt.heart.fill")
                            .font(.body.weight(.semibold))
                            .foregroundColor(accentGreen)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Live Harvest Alert")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("HealthKit Sync")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Spacer()

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.caption)
                        .foregroundColor(accentGreen.opacity(0.6))
                }

                Text(alert.message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: viewModel.logHarvest) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log Harvest")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [accentGreen, Color(red: 0.2, green: 0.85, blue: 0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
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
                            .strokeBorder(accentGreen.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: accentGreen.opacity(0.15), radius: 16, y: 8)
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
        }

        // Harvest logged confirmation
        if viewModel.harvestLogged {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(accentGreen)
                Text("Harvest logged! Recovery nutrition tracked.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accentGreen.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(accentGreen.opacity(0.15), lineWidth: 1)
                    )
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Goal Mismatch Alert

    @ViewBuilder
    private var targetMismatchCard: some View {
        if let alert = viewModel.targetMismatchAlert {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.yellow)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Goal Mismatch")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(alert)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.yellow.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.yellow.opacity(0.25), lineWidth: 1)
                    )
            )
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.fitnessGoal == .bulking
                         ? "Protein-to-Gain"
                         : "Greens-to-Lean")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(viewModel.fitnessGoal == .bulking
                         ? "7-day projected protein yield (\(viewModel.chartUnit))"
                         : "7-day projected nutrient yield (\(viewModel.chartUnit))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                Image(systemName: viewModel.fitnessGoal == .bulking
                      ? "figure.strengthtraining.traditional"
                      : "leaf.fill")
                    .foregroundColor(accentGreen.opacity(0.6))
            }

            Chart(viewModel.cropYields) { yield in
                // Filled area beneath the line
                AreaMark(
                    x: .value("Day", yield.day),
                    y: .value("Yield (g)", yield.proteinGrams)
                )
                .foregroundStyle(by: .value("Crop", yield.cropName))
                .interpolationMethod(.catmullRom)
                .opacity(0.1)

                // Main growth line
                LineMark(
                    x: .value("Day", yield.day),
                    y: .value("Yield (g)", yield.proteinGrams)
                )
                .foregroundStyle(by: .value("Crop", yield.cropName))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))

                // Per-day data points
                PointMark(
                    x: .value("Day", yield.day),
                    y: .value("Yield (g)", yield.proteinGrams)
                )
                .foregroundStyle(by: .value("Crop", yield.cropName))
                .symbolSize(36)
            }
            .chartForegroundStyleScale(domain: cropColorDomain, range: cropColorRange)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: .init(lineWidth: 0.3))
                        .foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel {
                        if let dblVal = value.as(Double.self) {
                            Text(formatAxisValue(dblVal))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .chartLegend(position: .bottom, spacing: 12)
            .frame(height: 220)
            .padding(.top, 4)
        }
        .padding(20)
        .background(lighterGlassCard)
    }

    // MARK: - Dynamic Chart Color Scale

    private let organicPalette: [Color] = [
        .green,
        .orange,
        .cyan,
        .purple,
        .yellow,
        .pink
    ]

    /// Ordered unique crop names — the domain for the chart's foreground style scale.
    private var cropColorDomain: [String] {
        viewModel.cropYields
            .map(\.cropName)
            .reduce(into: [String]()) { list, name in
                if !list.contains(name) { list.append(name) }
            }
    }

    /// Palette colors in the same order as cropColorDomain — the range.
    private var cropColorRange: [Color] {
        cropColorDomain.enumerated().map { idx, _ in
            organicPalette[idx % organicPalette.count]
        }
    }

    // MARK: - Axis Formatting

    /// Formats axis tick values with the dynamic unit from the view model.
    private func formatAxisValue(_ value: Double) -> String {
        if value == 0 { return "0" }
        if value < 1 {
            return String(format: "%.1f%@", value, viewModel.chartUnit)
        }
        return "\(Int(value))\(viewModel.chartUnit)"
    }

    // MARK: - Shared Card Styles


    private var glassCard: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
    }

    /// Slightly lighter card to stand out against the dark background
    private var lighterGlassCard: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

// MARK: - Crop Suggestion Sheet

private struct CropSuggestionSheet: View {
    let suggestions: [SuggestedCrop]
    let onPlant: (SuggestedCrop) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background matching the dashboard
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.04),
                        Color(red: 0.06, green: 0.14, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Hero header
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 36))
                                .foregroundColor(.teal)
                            Text("Smart Suggestions")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            Text("Tailored picks for your fitness goal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                        // Suggestion rows
                        ForEach(suggestions) { crop in
                            HStack(spacing: 14) {
                                // Crop icon
                                ZStack {
                                    Circle()
                                        .fill(Color.teal.opacity(0.15))
                                        .frame(width: 52, height: 52)
                                    Text(crop.icon)
                                        .font(.title2)
                                }

                                // Name & nutrient
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(crop.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(crop.primaryNutrient)
                                        .font(.caption)
                                        .foregroundColor(.teal.opacity(0.8))
                                }

                                Spacer()

                                // Plant Now button
                                Button {
                                    onPlant(crop)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "leaf.fill")
                                            .font(.caption)
                                        Text("Plant Now")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(
                                            LinearGradient(
                                                colors: [.green, Color(red: 0.2, green: 0.85, blue: 0.4)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    )
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.07))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

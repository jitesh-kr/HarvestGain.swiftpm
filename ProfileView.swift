import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var crops: [Crop]

    // Editable user data persisted across launches
    @AppStorage("userName") private var userName = ""
    @AppStorage("userProfession") private var userProfession = ""
    @AppStorage("fitnessGoal") private var storedGoal = FitnessGoal.bulking.rawValue

    @AppStorage("healthKitEnabled") private var healthKitEnabled = true
    @State private var dailyReminders = false

    // Edit / Save flow
    @State private var isEditing = false
    @State private var draftName = ""
    @State private var draftProfession = ""
    @State private var draftGoal = FitnessGoal.bulking.rawValue

    @StateObject private var healthManager = HealthSyncManager()

    private let accentGreen = Color.green

    private var fitnessGoal: FitnessGoal {
        FitnessGoal(rawValue: storedGoal) ?? .bulking
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Dynamic Header
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint, .teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(userName.isEmpty ? "Your Name" : userName)
                            .font(.title2.bold())

                        Text(userProfession.isEmpty ? "Your Profession" : userProfession)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        // Fitness goal badge
                        HStack(spacing: 6) {
                            Image(systemName: fitnessGoal.icon)
                                .font(.caption)
                            Text(fitnessGoal.rawValue)
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .listRowBackground(Color.clear)
                }

                // MARK: - Personal Details (Edit / Save flow)
                Section {
                    if isEditing {
                        HStack {
                            Label("Name", systemImage: "person.fill")
                            Spacer()
                            TextField("Your Name", text: $draftName)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(accentGreen)
                        }

                        HStack {
                            Label("Profession", systemImage: "briefcase.fill")
                            Spacer()
                            TextField("Your Profession", text: $draftProfession)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(accentGreen)
                        }

                        Picker(selection: $draftGoal) {
                            ForEach(FitnessGoal.allCases) { goal in
                                Label(goal.rawValue, systemImage: goal.icon)
                                    .tag(goal.rawValue)
                            }
                        } label: {
                            Label("Fitness Goal", systemImage: "flame.fill")
                        }
                    } else {
                        HStack {
                            Label("Name", systemImage: "person.fill")
                            Spacer()
                            Text(userName)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Label("Profession", systemImage: "briefcase.fill")
                            Spacer()
                            Text(userProfession)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Label("Fitness Goal", systemImage: "flame.fill")
                            Spacer()
                            Text(fitnessGoal.rawValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    HStack {
                        Text("Personal Details")
                        Spacer()
                        if isEditing {
                            HStack(spacing: 16) {
                                Button("Cancel") {
                                    withAnimation { isEditing = false }
                                }
                                .foregroundStyle(.secondary)

                                Button("Save") {
                                    userName = draftName.trimmingCharacters(in: .whitespaces)
                                    userProfession = draftProfession.trimmingCharacters(in: .whitespaces)
                                    storedGoal = draftGoal
                                    withAnimation { isEditing = false }
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(accentGreen)
                            }
                        } else {
                            Button("Edit") {
                                draftName = userName
                                draftProfession = userProfession
                                draftGoal = storedGoal
                                withAnimation { isEditing = true }
                            }
                            .foregroundStyle(accentGreen)
                        }
                    }
                }

                // MARK: - Garden Stats
                Section("Garden Stats") {
                    HStack {
                        Label("Total Seeds Planted", systemImage: "leaf.fill")
                        Spacer()
                        Text("\(crops.count)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(accentGreen)
                    }

                    HStack {
                        Label("Garden Maturity", systemImage: "chart.line.uptrend.xyaxis")
                        Spacer()
                        Text(maturityText)
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(maturityColor)
                    }
                }

                // MARK: - App Preferences
                Section("App Preferences") {
                    Toggle(isOn: $healthKitEnabled) {
                        Label("HealthKit Integration", systemImage: "heart.fill")
                    }
                    .tint(accentGreen)
                    .onChange(of: healthKitEnabled) { _, enabled in
                        if enabled {
                            Task {
                                await healthManager.requestAuthorization()
                            }
                        }
                    }

                    Toggle(isOn: $dailyReminders) {
                        Label("Daily Nutrient Reminders", systemImage: "bell.badge.fill")
                    }
                    .tint(accentGreen)
                }

                // MARK: - About (Read-Only)
                Section("About") {
                    HStack {
                        Label("App Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Developer", systemImage: "hammer.fill")
                        Spacer()
                        Text("Jitesh Kumar")
                            .foregroundStyle(.secondary)
                    }

                    Label("Member of Swift Coding Club (AACTCe) Parul University(India)", systemImage: "swift")
                        .foregroundStyle(accentGreen)
                   
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
        }
    }

    // MARK: - Computed Helpers

    private var averageMaturity: Double {
        guard !crops.isEmpty else { return 0 }
        let total = crops.reduce(0.0) { $0 + $1.currentYieldPercentage }
        return total / Double(crops.count)
    }

    private var maturityText: String {
        "\(Int(averageMaturity * 100))%"
    }

    private var maturityColor: Color {
        switch averageMaturity {
        case 0..<0.3:  return .teal
        case 0.3..<0.7: return .mint
        default:        return .green
        }
    }
}

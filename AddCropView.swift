import SwiftUI
import SwiftData

struct AddCropView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetNutrient = ""
    @State private var daysToPeak = 30
    @State private var plantDate = Date()
    @State private var baseValue: Double?
    @State private var baseUnit = "mg"

    private let unitOptions = ["g", "mg", "mcg", "%"]

    /// Whether the entered name matches a crop in the built-in nutrient library.
    private var isKnownCrop: Bool {
        isCropInLibrary(name)
    }

    /// Emoji icon matching the entered name (case-insensitive).
    private var emojiPreview: String {
        cropIcon(for: name)
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !targetNutrient.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // ── Crop Details ──────────────────────
                Section {
                    HStack(spacing: 12) {
                        // Live emoji preview
                        Text(emojiPreview)
                            .font(.largeTitle)
                            .frame(width: 44)
                            .animation(.easeInOut, value: emojiPreview)

                        TextField("Name (e.g. Spinach)", text: $name)
                    }

                    TextField("Target Nutrient (e.g. Protein)", text: $targetNutrient)

                    // Library status indicator
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: isKnownCrop
                                  ? "checkmark.circle.fill"
                                  : "info.circle")
                                .foregroundColor(isKnownCrop ? .green : .orange)
                            Text(isKnownCrop
                                 ? "Found in nutrient library"
                                 : "Not in library — add base value below")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Crop Details")
                }

                // ── Custom Base Value (only for unknown crops) ──
                if !isKnownCrop && !name.trimmingCharacters(in: .whitespaces).isEmpty {
                    Section {
                        HStack {
                            Text("Base Value")
                            Spacer()
                            TextField("e.g. 25.8", value: $baseValue, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }

                        Picker("Unit", selection: $baseUnit) {
                            ForEach(unitOptions, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                    } header: {
                        Text("Nutrient Base Value")
                    } footer: {
                        Text("Provide the nutrient amount per 100 g so the growth chart can track this crop accurately.")
                    }
                }

                // ── Growth Timeline ──────────────────
                Section("Growth Timeline") {
                    DatePicker(
                        "Plant Date",
                        selection: $plantDate,
                        displayedComponents: .date
                    )
                    Stepper(
                        "Days to Peak: \(daysToPeak)",
                        value: $daysToPeak,
                        in: 1...365
                    )
                }
            }
            .navigationTitle("Plant a Seed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Helpers

    private func save() {
        let crop = Crop(
            name: name.trimmingCharacters(in: .whitespaces),
            plantDate: plantDate,
            targetNutrient: targetNutrient.trimmingCharacters(in: .whitespaces),
            daysToPeak: daysToPeak,
            customBaseValue: isKnownCrop ? nil : baseValue,
            customUnit: isKnownCrop ? nil : baseUnit
        )
        modelContext.insert(crop)
    }
}

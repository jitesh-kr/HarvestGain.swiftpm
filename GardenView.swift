import SwiftUI
import SwiftData

struct GardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var crops: [Crop]
    @State private var showingAddCrop = false

    var body: some View {
        NavigationStack {
            Group {
                if crops.isEmpty {
                    ContentUnavailableView(
                        "Your garden is empty. Plant some seeds!",
                        systemImage: "leaf",
                        description: Text("Tap the + button to add your first crop.")
                    )
                } else {
                    List {
                        ForEach(crops) { crop in
                            CropRow(crop: crop)
                        }
                        .onDelete(perform: deleteCrops)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Garden")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCrop = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                if !crops.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddCrop) {
                AddCropView()
            }
        }
    }

    private func deleteCrops(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(crops[index])
        }
    }
}

// MARK: - Crop Row

private struct CropRow: View {
    let crop: Crop

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Emoji icon
                Text(cropIcon(for: crop.name))
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(crop.name)
                        .font(.headline)
                    Text(crop.targetNutrient)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(Int(crop.currentYieldPercentage * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: crop.currentYieldPercentage)
                .tint(progressColor(for: crop.currentYieldPercentage))
        }
        .padding(.vertical, 4)
    }

    private func progressColor(for value: Double) -> Color {
        switch value {
        case 0..<0.4:  return .teal
        case 0.4..<0.8: return .mint
        default:        return .green
        }
    }
}


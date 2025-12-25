//
//  ExercisePickerView.swift
//  FitnessTracker
//

import SwiftUI

struct ExercisePickerView: View {
    @Binding var exercises: [ExerciseDTO]
    let onSelect: (ExerciseDTO) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                Text("Exercises: \(exercises.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                ForEach(exercises, id: \.id) { ex in
                    Button {
                        onSelect(ex)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ex.name)
                                .foregroundStyle(.primary)

                            if !ex.category.isEmpty {
                                Text(ex.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Choose Exercise")
    }
}

#Preview {
    struct Wrapper: View {
        @State var list: [ExerciseDTO] = [
            .init(id: 1, name: "Bench Press", category: "Strength"),
            .init(id: 2, name: "Squat", category: "Strength"),
            .init(id: 3, name: "Deadlift", category: "")
        ]

        var body: some View {
            NavigationStack {
                ExercisePickerView(exercises: $list) { _ in }
            }
        }
    }

    return Wrapper()
}

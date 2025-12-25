//
//  WorkoutView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(AppState.self) private var appState

    @State private var workout: WorkoutDetailDTO?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddSetSheet = false

    @State private var setRepsText = ""
    @State private var setWeightText = ""
    @State private var setDurationText = ""
    @State private var setDistanceText = ""

    @State private var selectedExerciseId: Int?
    @State private var selectedExerciseName: String?

    @State private var allExercises: [ExerciseDTO] = []
    @State private var exerciseCache = ExerciseCache()

    private let api = APIClient()

    var body: some View {
        NavigationStack {
            Group {
                if let id = appState.activeWorkoutId {
                    content(for: id)
                } else {
                    ContentUnavailableView(
                        "No active workout",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Start a workout from a plan.")
                    )
                }
            }
            .onAppear {
                if let id = appState.activeWorkoutId {
                    Task { @MainActor in
                        await loadWorkout(id: id)
                    }
                }
            }
            .onChange(of: appState.activeWorkoutId) { _, newValue in
                guard let id = newValue else { return }
                Task { @MainActor in
                    await loadWorkout(id: id)
                }
            }
            .navigationTitle("Workout")
            .toolbar {
                if let id = appState.activeWorkoutId {
                    Button("Add Set") {
                        Task { @MainActor in
                            await loadExercisesIfNeeded()
                            showAddSetSheet = true
                        }
                    }

                    Button("End") {
                        Task { @MainActor in
                            await endWorkout(id: id)
                        }
                    }

                    Button("Clear") {
                        appState.clearActiveWorkout()
                    }
                }
            }
            .sheet(isPresented: $showAddSetSheet) {
                NavigationStack {
                    Form {
                        // Optional Debug: zeigt ob das Sheet wirklich die Exercises sieht
                        Section {
                            Text("Loaded exercises in sheet: \(allExercises.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Section("Exercise") {
                            NavigationLink {
                                // ✅ Binding, damit der Picker Updates garantiert sieht
                                ExercisePickerView(exercises: $allExercises) { ex in
                                    selectedExerciseId = ex.id
                                    selectedExerciseName = ex.name
                                }
                            } label: {
                                HStack {
                                    Text("Exercise")
                                    Spacer()
                                    Text(selectedExerciseName ?? "Choose")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Section("Strength (optional)") {
                            TextField("Reps", text: $setRepsText)
                                .keyboardType(.numberPad)
                            TextField("Weight (kg)", text: $setWeightText)
                                .keyboardType(.decimalPad)
                        }

                        Section("Time / Distance (optional)") {
                            TextField("Duration (seconds)", text: $setDurationText)
                                .keyboardType(.numberPad)
                            TextField("Distance (meters)", text: $setDistanceText)
                                .keyboardType(.numberPad)
                        }

                        Section {
                            Button("Save Set") {
                                guard let workoutId = appState.activeWorkoutId else { return }
                                Task { @MainActor in
                                    await createSet(workoutId: workoutId)
                                }
                            }
                        }
                    }
                    .navigationTitle("Add Set")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAddSetSheet = false }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func content(for workoutId: Int) -> some View {
        if isLoading {
            ProgressView("Loading workout…")
        } else if let errorMessage {
            VStack(spacing: 12) {
                Text("Failed to load workout")
                    .font(.headline)
                Text(errorMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task { await loadWorkout(id: workoutId) }
                }
            }
            .padding()
        } else if let workout {
            List {
                Section("Status") {
                    Text("Workout #\(workout.id)")
                        .font(.headline)

                    Text("Started: \(workout.startedAt)")
                        .foregroundStyle(.secondary)

                    if let endedAt = workout.endedAt {
                        Text("Ended: \(endedAt)")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("In progress")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Sets") {
                    if workout.sets.isEmpty {
                        Text("No sets yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(workout.sets) { set in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(exerciseCache.name(for: set.exerciseId) ?? "Exercise #\(set.exerciseId)")
                                    .font(.headline)

                                Text("Set \(set.setNumber) • \(setLine(set))")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .refreshable {
                await loadWorkout(id: workoutId)
            }
        } else {
            ContentUnavailableView("No data", systemImage: "exclamationmark.triangle")
        }
    }

    private func tokenOrNil() -> String? {
        if case let .authenticated(accessToken) = appState.session { return accessToken }
        return nil
    }

    private func prettyError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidResponse:
                return "Invalid response from server."
            case .httpStatus(let code):
                if code == 401 { return "Unauthorized (401). Please log in." }
                if code == 404 { return "Not found (404)." }
                return "Server returned HTTP \(code)."
            }
        }
        return String(describing: error)
    }

    private func setLine(_ set: WorkoutSetDTO) -> String {
        var parts: [String] = []
        if let reps = set.reps { parts.append("\(reps) reps") }
        if let kg = set.weightKg { parts.append(String(format: "%.1f kg", kg)) }
        if let sec = set.durationSeconds { parts.append("\(sec) sec") }
        if let m = set.distanceMeters { parts.append("\(m) m") }
        return parts.isEmpty ? "—" : parts.joined(separator: " • ")
    }

    private func loadWorkout(id: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let token = tokenOrNil() else {
            errorMessage = "Unauthorized (401). Please log in."
            return
        }

        do {
            let res: WorkoutDetailDTO = try await api.get("workouts/\(id)", accessToken: token)
            workout = res

            let ids = res.sets.map { $0.exerciseId }
            await exerciseCache.preload(ids: ids, accessToken: token)
        } catch {
            errorMessage = prettyError(error)
        }
    }

    private func loadExercisesIfNeeded() async {
        if !allExercises.isEmpty { return }
        guard let token = tokenOrNil() else { return }

        do {
            allExercises = try await api.get("exercises", accessToken: token)
            print("Loaded exercises:", allExercises.count)
        } catch {
            print("Failed to load exercises:", error)
        }
    }

    private func endWorkout(id: Int) async {
        guard let token = tokenOrNil() else {
            errorMessage = "Unauthorized (401). Please log in."
            return
        }

        do {
            let _: EndWorkoutResponseDTO = try await api.post(
                "workouts/\(id)/end",
                body: EmptyBody(),
                accessToken: token
            )
            await loadWorkout(id: id)
            appState.clearActiveWorkout()
        } catch {
            errorMessage = prettyError(error)
        }
    }

    private func createSet(workoutId: Int) async {
        errorMessage = nil

        guard let token = tokenOrNil() else {
            errorMessage = "Unauthorized (401). Please log in."
            return
        }

        guard let exerciseId = selectedExerciseId else {
            errorMessage = "Please choose an exercise."
            return
        }

        let reps = Int(setRepsText.trimmingCharacters(in: .whitespacesAndNewlines))
        let weightKg = Double(setWeightText.trimmingCharacters(in: .whitespacesAndNewlines))
        let durationSeconds = Int(setDurationText.trimmingCharacters(in: .whitespacesAndNewlines))
        let distanceMeters = Int(setDistanceText.trimmingCharacters(in: .whitespacesAndNewlines))

        let currentSets = workout?.sets.filter { $0.exerciseId == exerciseId } ?? []
        let nextSetNumber = (currentSets.map(\.setNumber).max() ?? 0) + 1

        let body = CreateWorkoutSetRequestDTO(
            exerciseId: exerciseId,
            setNumber: nextSetNumber,
            reps: reps,
            weightKg: weightKg,
            durationSeconds: durationSeconds,
            distanceMeters: distanceMeters
        )

        do {
            let _: CreateWorkoutSetResponseDTO = try await api.post(
                "workouts/\(workoutId)/sets",
                body: body,
                accessToken: token
            )

            // reset form
            setRepsText = ""
            setWeightText = ""
            setDurationText = ""
            setDistanceText = ""
            selectedExerciseId = nil
            selectedExerciseName = nil

            showAddSetSheet = false
            await loadWorkout(id: workoutId)
        } catch {
            errorMessage = prettyError(error)
        }
    }
}

#Preview {
    let state = AppState()
    state.startWorkout(id: 1)
    return WorkoutView()
        .environment(state)
}

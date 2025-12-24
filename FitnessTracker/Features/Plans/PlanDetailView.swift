//
//  PlanDetailView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//


import SwiftUI

struct PlanDetailView: View {
    @Environment(AppState.self) private var appState

    let planId: Int
    @State private var plan: WorkoutPlanDetailDTO?

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var exerciseCache = ExerciseCache()

    private let api = APIClient()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading plan…")
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Failed to load plan")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        Task { await load() }
                    }
                }
                .padding()
            } else if let plan {
                List {
                    Section {
                        Text(plan.name)
                            .font(.title2).bold()
                    }

                    Section("Exercises") {
                        ForEach(plan.items.sorted(by: { $0.position < $1.position })) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(exerciseCache.name(for: item.exerciseId) ?? "Exercise #\(item.exerciseId)")
                                    .font(.headline)

                                Text(targetLine(item))
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            } else {
                ContentUnavailableView("No data", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let token: String? = {
            if case let .authenticated(accessToken) = appState.session { return accessToken }
            return nil
        }()

        do {
            plan = try await api.get("plans/\(planId)", accessToken: token)
            if let plan {
                let ids = plan.items.map { $0.exerciseId }
                await exerciseCache.preload(ids: ids, accessToken: token)
            }
        } catch {
            errorMessage = prettyError(error)
        }
    }

    private func prettyError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidResponse:
                return "Invalid response from server."
            case .httpStatus(let code):
                if code == 401 { return "Unauthorized (401). Please log in." }
                if code == 404 { return "Plan not found (404)." }
                return "Server returned HTTP \(code)."
            }
        }
        return String(describing: error)
    }

    private func targetLine(_ item: WorkoutPlanItemDTO) -> String {
        var parts: [String] = []

        if let sets = item.targetSets { parts.append("\(sets) sets") }
        if let reps = item.targetReps { parts.append("\(reps) reps") }
        if let kg = item.targetWeightKg { parts.append(String(format: "%.1f kg", kg)) }
        if let sec = item.targetDurationSeconds { parts.append("\(sec) sec") }
        if let m = item.targetDistanceMeters { parts.append("\(m) m") }

        return parts.isEmpty ? "No targets" : parts.joined(separator: " • ")
    }
}

#Preview("Guest") {
    NavigationStack {
        PlanDetailView(planId: 1)
            .environment(AppState())
    }
}

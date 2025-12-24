//
//  PlansView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct PlansView: View {
    @Environment(AppState.self) private var appState

    @State private var plans: [WorkoutPlanDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = APIClient()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading plans…")
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load plans")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task { await loadPlans() }
                        }
                    }
                    .padding()
                } else if plans.isEmpty {
                    ContentUnavailableView(
                        "No plans yet",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Create your first plan (for now via backend).")
                    )
                } else {
                    List(plans) { plan in
                        NavigationLink(plan.name) {
                            PlanDetailView(planId: plan.id)
                        }
                    }
                }
            }
            .navigationTitle("Plans")
            .toolbar {
                Button {
                    Task { await loadPlans() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task {
                await loadPlans()
            }
        }
    }

    private func loadPlans() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let token: String? = {
            if case let .authenticated(accessToken) = appState.session {
                return accessToken
            }
            return nil
        }()

        do {
            plans = try await api.get("plans", accessToken: token)
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
                if code == 401 {
                    return "Unauthorized (401). Please log in."
                }
                return "Server returned HTTP \(code)."
            }
        }
        return String(describing: error)
    }
}

#Preview("Guest") {
    PlansView()
        .environment(AppState())
}

#Preview("Logged In (fake token)") {
    let state = AppState()
    state.login(accessToken: "preview-token")
    return PlansView()
        .environment(state)
}

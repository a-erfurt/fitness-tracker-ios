//
//  WorkoutView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Workout")
                    .font(.largeTitle).bold()

                if let id = appState.activeWorkoutId {
                    Text("Active Workout: #\(id)")
                        .font(.headline)
                } else {
                    Text("No active workout")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .navigationTitle("Workout")
        }
    }
}

#Preview {
    let state = AppState()
    state.startWorkout(id: 123)
    return WorkoutView()
        .environment(state)
}

//
//  WorkoutView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct WorkoutView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Workout")
                    .font(.largeTitle).bold()
                Text("Later: start/end workout, log sets (tracking_type decides UI)")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Workout")
        }
    }
}

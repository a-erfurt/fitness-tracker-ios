//
//  RootView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            WorkoutView()
                .tabItem { Label("Workout", systemImage: "figure.strengthtraining.traditional") }

            PlansView()
                .tabItem { Label("Plans", systemImage: "list.bullet.rectangle") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

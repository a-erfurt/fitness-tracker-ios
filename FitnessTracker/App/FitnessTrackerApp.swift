//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

@main
struct FitnessTrackerApp: App {
    @State private var appState = AppState()

        var body: some Scene {
            WindowGroup {
                RootView()
                    .environment(appState)
            }
        }
}

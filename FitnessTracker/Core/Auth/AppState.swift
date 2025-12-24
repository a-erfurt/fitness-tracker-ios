//
//  AppState.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import Foundation
import Observation

@Observable
final class AppState {
    enum SessionState {
        case guest
        case authenticated(accessToken: String)
    }
    
    enum Tab: Hashable {
        case home
        case workout
        case plans
        case profile
    }

    var selectedTab: Tab = .home
    var activeWorkoutId: Int?

    var session: SessionState = .guest

    var isAuthenticated: Bool {
        if case .authenticated = session { return true }
        return false
    }

    func login(accessToken: String) {
        session = .authenticated(accessToken: accessToken)
    }

    func logout() {
        session = .guest
    }
    
    func startWorkout(id: Int) {
        activeWorkoutId = id
        selectedTab = .workout
    }

    func clearActiveWorkout() {
        activeWorkoutId = nil
    }
}

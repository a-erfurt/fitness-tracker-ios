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
}

//
//  ProfileView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Profile")
                    .font(.largeTitle).bold()

                if appState.isAuthenticated {
                    Text("Status: Logged in")
                    Button("Logout") { appState.logout() }
                } else {
                    Text("Status: Guest")
                    Button("Fake Login (for now)") { appState.login(accessToken: "demo-token") }
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

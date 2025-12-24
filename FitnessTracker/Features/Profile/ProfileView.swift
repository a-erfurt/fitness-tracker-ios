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

                    NavigationLink("Login") {
                        LoginView()
                    }
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview("Guest") {
    ProfileView()
        .environment(AppState())
}

#Preview("Logged In") {
    let state = AppState()
    state.login(accessToken: "preview-token")
    return ProfileView()
        .environment(state)
}

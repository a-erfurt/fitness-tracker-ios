//
//  LoginView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState

    @State private var email = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = APIClient()

    var body: some View {
        Form {
            Section("Account") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await login() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Login")
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
            }
        }
        .navigationTitle("Login")
    }

    private func login() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let res: LoginResponseDTO = try await api.post(
                "auth/login",
                body: LoginRequestDTO(email: email, password: password)
            )
            appState.login(accessToken: res.accessToken)
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
                    return "Wrong email or password."
                }
                return "Server returned HTTP \(code)."
            }
        }
        return String(describing: error)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environment(AppState())
    }
}

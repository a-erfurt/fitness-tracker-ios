//
//  APIClient.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case httpStatus(Int)
}

struct APIClient {
    func get<T: Decodable>(
        _ path: String,
        accessToken: String?
    ) async throws -> T {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

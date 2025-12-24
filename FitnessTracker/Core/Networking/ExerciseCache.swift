//
//  ExerciseCache.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//


import Foundation
import Observation

@MainActor
@Observable
final class ExerciseCache {
    var namesById: [Int: String] = [:]

    private let api = APIClient()

    func name(for id: Int) -> String? {
        namesById[id]
    }

    func preload(ids: [Int], accessToken: String?) async {
        let missing = Set(ids).subtracting(namesById.keys)
        guard !missing.isEmpty else { return }

        do {
            let all: [ExerciseDTO] = try await api.get("exercises", accessToken: accessToken)
            var dict: [Int: String] = [:]
            for ex in all { dict[ex.id] = ex.name }
            namesById.merge(dict) { old, _ in old }
        } catch {
            // silent fail for MVP
        }
    }
}

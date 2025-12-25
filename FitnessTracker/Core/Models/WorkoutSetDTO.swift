//
//  WorkoutSetDTO.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//


import Foundation

struct WorkoutSetDTO: Identifiable, Decodable {
    let id: Int
    let exerciseId: Int
    let setNumber: Int

    let reps: Int?
    let weightKg: Double?
    let durationSeconds: Int?
    let distanceMeters: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case exerciseId = "exercise_id"
        case setNumber = "set_number"
        case reps
        case weightKg = "weight_kg"
        case durationSeconds = "duration_seconds"
        case distanceMeters = "distance_meters"
    }
}

struct WorkoutDetailDTO: Identifiable, Decodable {
    let id: Int
    let startedAt: String
    let endedAt: String?
    let sets: [WorkoutSetDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case sets
    }
}

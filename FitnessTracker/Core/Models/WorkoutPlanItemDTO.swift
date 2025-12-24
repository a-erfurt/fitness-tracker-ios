//
//  WorkoutPlanItemDTO.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import Foundation

struct WorkoutPlanItemDTO: Identifiable, Decodable {
    let id: Int
    let exerciseId: Int
    let position: Int

    let targetSets: Int?
    let targetReps: Int?
    let targetWeightKg: Double?
    let targetDurationSeconds: Int?
    let targetDistanceMeters: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case exerciseId = "exercise_id"
        case position
        case targetSets = "target_sets"
        case targetReps = "target_reps"
        case targetWeightKg = "target_weight_kg"
        case targetDurationSeconds = "target_duration_seconds"
        case targetDistanceMeters = "target_distance_meters"
    }
}

struct WorkoutPlanDetailDTO: Identifiable, Decodable {
    let id: Int
    let name: String
    let items: [WorkoutPlanItemDTO]
}

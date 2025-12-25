//
//  EndWorkoutResponseDTO.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//


import Foundation

struct EndWorkoutResponseDTO: Decodable {
    let id: Int
    let endedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case endedAt = "ended_at"
    }
}
//
//  StartWorkoutFromPlanResponseDTO.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//


import Foundation

struct StartWorkoutFromPlanResponseDTO: Decodable {
    let id: Int
    let createdSets: Int

    enum CodingKeys: String, CodingKey {
        case id
        case createdSets = "created_sets"
    }
}
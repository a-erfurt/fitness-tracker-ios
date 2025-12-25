//
//  ExerciseDTO.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//


import Foundation

struct ExerciseDTO: Identifiable, Decodable {
    let id: Int
    let name: String
    let category: String
}

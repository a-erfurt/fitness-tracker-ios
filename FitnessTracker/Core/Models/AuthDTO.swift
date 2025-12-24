//
//  AuthDTO.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

// Passe die Felder an, falls dein Backend anders antwortet.
// Häufig: access_token, token_type
struct LoginResponseDTO: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

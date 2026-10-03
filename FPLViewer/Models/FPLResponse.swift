//
//  FPLResponse.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

struct FPLResponse: Codable {
    let teams: [Team]
    let elements: [Player]
    let elementTypes: [ElementType]

    enum CodingKeys: String, CodingKey {
        case teams, elements
        case elementTypes = "element_types"
    }
}

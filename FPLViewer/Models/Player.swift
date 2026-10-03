//
//  Player.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

struct Player: Codable {
    let id: Int
    let firstName: String
    let secondName: String
    let webName: String
    let team: Int
    let elementType: Int
    let totalPoints: Int
    let nowCost: Int
    let selectedByPercent: String
    let pointsPerGame: String
    let form: String
    let status: String
    let minutes: Int

    enum CodingKeys: String, CodingKey {
        case id, team, status, minutes, form
        case firstName        = "first_name"
        case secondName       = "second_name"
        case webName          = "web_name"
        case elementType      = "element_type"
        case totalPoints      = "total_points"
        case nowCost          = "now_cost"
        case selectedByPercent = "selected_by_percent"
        case pointsPerGame    = "points_per_game"
    }

    // MARK: - Computed
    var fullName: String   { "\(firstName) \(secondName)" }
    var priceString: String { "£\(String(format: "%.1f", Double(nowCost) / 10.0))m" }
    var isAvailable: Bool  { status == "a" }
    
    // Inside the Player struct, after existing computed properties
    var positionName: String {
        switch elementType {
        case 1: return "Goalkeeper"
        case 2: return "Defender"
        case 3: return "Midfielder"
        case 4: return "Forward"
        default: return "Unknown"
        }
    }
}

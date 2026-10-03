//
//  Team.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

struct Team: Codable {
    let id: Int
    let code: Int
    let name: String
    let shortName: String
    let played: Int
    let win: Int
    let draw: Int
    let loss: Int
    let position: Int

    enum CodingKeys: String, CodingKey {
        case id, code, name, played, win, draw, loss, position
        case shortName = "short_name"
    }
}

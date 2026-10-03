//
//  ElementType.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

struct ElementType: Codable {
    let id: Int
    let pluralName: String
    let pluralNameShort: String
    let singularName: String

    enum CodingKeys: String, CodingKey {
        case id
        case pluralName      = "plural_name"
        case pluralNameShort = "plural_name_short"
        case singularName    = "singular_name"
    }
}

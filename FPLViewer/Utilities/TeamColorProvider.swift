//
//  TeamColorProvider.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import UIKit

struct TeamColorProvider {

    private static let palette: [UIColor] = [
        hex("E63946"),   // red
        hex("2196F3"),   // blue
        hex("4CAF50"),   // green
        hex("FF9800"),   // orange
        hex("9C27B0"),   // purple
        hex("00BCD4"),   // cyan
        hex("3F51B5"),   // indigo
        hex("009688"),   // teal
        hex("FF5722"),   // deep orange
        hex("607D8B"),   // blue grey
    ]

    static func color(forTeamId id: Int) -> UIColor {
        return palette[id % palette.count]
    }

    // Private helper — converts hex string to UIColor, no extension needed
    private static func hex(_ hex: String) -> UIColor {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        return UIColor(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8)  & 0xFF) / 255,
            blue:  CGFloat(rgb         & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Int {
    // Converts 1 → "1st", 2 → "2nd", 3 → "3rd", 4 → "4th", 11 → "11th"
    var ordinalString: String {
        let suffix: String
        switch self % 100 {
        case 11, 12, 13:         suffix = "th"   // special: 11th, 12th, 13th
        default:
            switch self % 10 {
            case 1:              suffix = "st"
            case 2:              suffix = "nd"
            case 3:              suffix = "rd"
            default:             suffix = "th"
            }
        }
        return "\(self)\(suffix)"
    }
}

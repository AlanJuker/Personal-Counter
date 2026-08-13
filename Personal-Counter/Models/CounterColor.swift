//
//  CounterColor.swift
//  Personal-Counter
//
//  The palette used to tint counter cards.
//

import SwiftUI

/// A named tint for a counter card. Stored on the model by `rawValue` so the
/// palette can grow without migrating existing data.
enum CounterColor: String, CaseIterable, Identifiable, Codable {
    case emerald
    case ocean
    case violet
    case magenta
    case coral
    case amber
    case lime
    case slate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .emerald: "Emerald"
        case .ocean: "Ocean"
        case .violet: "Violet"
        case .magenta: "Magenta"
        case .coral: "Coral"
        case .amber: "Amber"
        case .lime: "Lime"
        case .slate: "Slate"
        }
    }

    var color: Color {
        switch self {
        case .emerald: Color(red: 0.13, green: 0.78, blue: 0.60)
        case .ocean: Color(red: 0.13, green: 0.71, blue: 0.95)
        case .violet: Color(red: 0.48, green: 0.48, blue: 0.96)
        case .magenta: Color(red: 0.96, green: 0.37, blue: 0.69)
        case .coral: Color(red: 1.00, green: 0.48, blue: 0.36)
        case .amber: Color(red: 0.96, green: 0.73, blue: 0.23)
        case .lime: Color(red: 0.61, green: 0.85, blue: 0.31)
        case .slate: Color(red: 0.54, green: 0.58, blue: 0.65)
        }
    }

    /// Text/glyph color that stays legible on top of `color`.
    var foreground: Color { .white }

    /// The palette entry that follows this one, used by `ColorAssignment.cycle`.
    var next: CounterColor {
        let all = CounterColor.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}

/// How a color is picked for a newly created counter.
enum ColorAssignment: String, CaseIterable, Identifiable, Codable {
    case cycle
    case random
    case fixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cycle: "Cycle through palette"
        case .random: "Random"
        case .fixed: "Always the same"
        }
    }
}

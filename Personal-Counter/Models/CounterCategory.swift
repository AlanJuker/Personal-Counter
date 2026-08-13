//
//  CounterCategory.swift
//  Personal-Counter
//
//  Groups counters together — "Pull ups", "Cindy Routines", …
//

import Foundation
import SwiftData

@Model
final class CounterCategory {
    var name: String = ""
    var colorID: String = CounterColor.emerald.rawValue
    var symbolName: String = CategorySymbol.defaultName
    var sortIndex: Int = 0
    var createdAt: Date = Date.now

    /// Counters lose their category rather than being deleted with it.
    @Relationship(deleteRule: .nullify, inverse: \Counter.category)
    var counters: [Counter]?

    init(
        name: String,
        color: CounterColor = .emerald,
        symbolName: String = CategorySymbol.defaultName,
        sortIndex: Int = 0,
        createdAt: Date = .now
    ) {
        self.name = name
        self.colorID = color.rawValue
        self.symbolName = symbolName
        self.sortIndex = sortIndex
        self.createdAt = createdAt
        self.counters = []
    }

    var color: CounterColor {
        get { CounterColor(rawValue: colorID) ?? .emerald }
        set { colorID = newValue.rawValue }
    }

    var counterCount: Int { counters?.count ?? 0 }

    var total: Int { (counters ?? []).reduce(0) { $0 + $1.count } }
}

/// The symbols offered when naming a category.
enum CategorySymbol {
    static let defaultName = "square.grid.2x2.fill"

    static let all: [String] = [
        "square.grid.2x2.fill",
        "figure.strengthtraining.traditional",
        "figure.run",
        "figure.cooldown",
        "dumbbell.fill",
        "heart.fill",
        "flame.fill",
        "bolt.fill",
        "drop.fill",
        "leaf.fill",
        "book.fill",
        "brain.head.profile",
        "cup.and.saucer.fill",
        "pills.fill",
        "moon.fill",
        "star.fill",
        "checkmark.circle.fill",
        "number",
    ]
}

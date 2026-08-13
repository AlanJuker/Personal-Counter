//
//  Counter.swift
//  Personal-Counter
//
//  The persisted counter model.
//

import Foundation
import SwiftData

@Model
final class Counter {
    /// Full label shown on the card, e.g. "Pull ups 13/08/2026".
    var title: String = ""
    /// The name part of the label, kept so renaming the date format is possible later.
    var name: String = ""
    var count: Int = 0
    /// How much a single tap adds.
    var step: Int = 1
    /// Target for the card's progress bar. `0` means "no goal".
    var goal: Int = 0
    var colorID: String = CounterColor.emerald.rawValue
    /// Locked counters ignore taps and cannot be deleted by swiping.
    var isLocked: Bool = false
    var allowsNegative: Bool = false
    var notes: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    /// Position used by the manual sort order.
    var sortIndex: Int = 0

    init(
        title: String,
        name: String = "",
        count: Int = 0,
        step: Int = 1,
        goal: Int = 0,
        color: CounterColor = .emerald,
        isLocked: Bool = false,
        allowsNegative: Bool = false,
        notes: String = "",
        createdAt: Date = .now,
        sortIndex: Int = 0
    ) {
        self.title = title
        self.name = name
        self.count = count
        self.step = step
        self.goal = goal
        self.colorID = color.rawValue
        self.isLocked = isLocked
        self.allowsNegative = allowsNegative
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.sortIndex = sortIndex
    }

    var color: CounterColor {
        get { CounterColor(rawValue: colorID) ?? .emerald }
        set { colorID = newValue.rawValue }
    }

    /// Progress towards `goal`, or `nil` when no goal is set.
    var progress: Double? {
        guard goal > 0 else { return nil }
        return min(max(Double(count) / Double(goal), 0), 1)
    }

    var hasReachedGoal: Bool { goal > 0 && count >= goal }

    // MARK: - Mutations

    func increment(by amount: Int? = nil) {
        apply(delta: amount ?? step)
    }

    func decrement(by amount: Int? = nil) {
        apply(delta: -(amount ?? step))
    }

    func reset() {
        count = 0
        updatedAt = .now
    }

    private func apply(delta: Int) {
        let proposed = count + delta
        count = allowsNegative ? proposed : max(0, proposed)
        updatedAt = .now
    }
}

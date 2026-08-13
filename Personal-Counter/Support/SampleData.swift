//
//  SampleData.swift
//  Personal-Counter
//
//  Demo counters used by SwiftUI previews and by the `-demoData` launch
//  argument, which runs the app on a throwaway in-memory store.
//

import Foundation
import SwiftData

enum SampleData {
    static let launchArgument = "-demoData"

    static var isRequested: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    /// Inserts a week of "Pull ups" counters ending today.
    @discardableResult
    static func populate(_ context: ModelContext, name: String = "Pull ups", days: Int = 9) -> [Counter] {
        let calendar = Calendar.current
        var created: [Counter] = []

        for offset in stride(from: days - 1, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let counter = Counter(
                title: "\(name) \(DateLabelFormat.dayMonth.string(from: date))",
                name: name,
                count: 58 + (days - 1 - offset),
                step: 1,
                goal: 0,
                color: offset < 3 ? .ocean : .emerald,
                isLocked: offset > 0,
                createdAt: date,
                sortIndex: days - offset
            )
            context.insert(counter)
            created.append(counter)
        }

        return created
    }
}

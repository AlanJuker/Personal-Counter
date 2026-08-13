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

    /// Inserts two categories and a run of daily counters ending today.
    static func populate(_ context: ModelContext) {
        let pullUps = CounterCategory(
            name: "Pull ups",
            color: .emerald,
            symbolName: "figure.strengthtraining.traditional",
            sortIndex: 0
        )
        let cindy = CounterCategory(
            name: "Cindy Routines",
            color: .ocean,
            symbolName: "figure.cooldown",
            sortIndex: 1
        )
        context.insert(pullUps)
        context.insert(cindy)

        let calendar = Calendar.current

        for offset in stride(from: 8, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            context.insert(Counter(
                title: "\(pullUps.name) \(DateLabelFormat.dayMonth.string(from: date))",
                name: pullUps.name,
                count: 58 + (8 - offset),
                color: pullUps.color,
                isLocked: offset > 0,
                createdAt: date,
                sortIndex: 8 - offset,
                category: pullUps
            ))
        }

        for offset in stride(from: 3, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            context.insert(Counter(
                title: "\(cindy.name) \(DateLabelFormat.dayMonth.string(from: date))",
                name: cindy.name,
                count: 12 + offset,
                goal: 20,
                color: cindy.color,
                isLocked: offset > 0,
                createdAt: date,
                sortIndex: 20 + (3 - offset),
                category: cindy
            ))
        }
    }
}

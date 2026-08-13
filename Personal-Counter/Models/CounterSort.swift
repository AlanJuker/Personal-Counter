//
//  CounterSort.swift
//  Personal-Counter
//
//  Sorting and scope options for the counter list.
//

import Foundation

enum CounterSortField: String, CaseIterable, Identifiable, Codable {
    case manual
    case createdAt
    case updatedAt
    case title
    case count

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .manual: "Custom order"
        case .createdAt: "Date created"
        case .updatedAt: "Last updated"
        case .title: "Name"
        case .count: "Count"
        }
    }

    var symbolName: String {
        switch self {
        case .manual: "hand.draw"
        case .createdAt: "calendar"
        case .updatedAt: "clock.arrow.circlepath"
        case .title: "textformat"
        case .count: "number"
        }
    }
}

enum CounterScope: String, CaseIterable, Identifiable, Codable {
    case all
    case today

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "All"
        case .today: "Today"
        }
    }
}

/// Which timestamp the "Today" tab filters on.
enum TodayBasis: String, CaseIterable, Identifiable, Codable {
    case created
    case updated

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .created: "Created today"
        case .updated: "Updated today"
        }
    }
}

enum CounterOrdering {
    /// Applies scope + sort field + direction to a list of counters.
    static func arrange(
        _ counters: [Counter],
        scope: CounterScope,
        todayBasis: TodayBasis,
        field: CounterSortField,
        ascending: Bool,
        calendar: Calendar = .current,
        now: Date = .now
    ) -> [Counter] {
        let scoped: [Counter]
        switch scope {
        case .all:
            scoped = counters
        case .today:
            scoped = counters.filter { counter in
                let date = todayBasis == .created ? counter.createdAt : counter.updatedAt
                return calendar.isDate(date, inSameDayAs: now)
            }
        }

        let sorted = scoped.sorted { lhs, rhs in
            switch field {
            case .manual:
                if lhs.sortIndex != rhs.sortIndex { return lhs.sortIndex < rhs.sortIndex }
                return lhs.createdAt < rhs.createdAt
            case .createdAt:
                return lhs.createdAt < rhs.createdAt
            case .updatedAt:
                return lhs.updatedAt < rhs.updatedAt
            case .title:
                return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            case .count:
                if lhs.count != rhs.count { return lhs.count < rhs.count }
                return lhs.createdAt < rhs.createdAt
            }
        }

        return ascending ? sorted : sorted.reversed()
    }
}

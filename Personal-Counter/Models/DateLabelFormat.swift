//
//  DateLabelFormat.swift
//  Personal-Counter
//
//  How the current day/month/year is rendered into a new counter's label.
//

import Foundation

enum DateLabelFormat: String, CaseIterable, Identifiable, Codable {
    /// 13/08/2026
    case dayMonthYear
    /// 13/08/26
    case dayMonthShortYear
    /// 13/08
    case dayMonth
    /// 2026-08-13
    case yearMonthDay
    /// 13 Aug 2026, localized
    case localizedMedium
    /// Thursday 13 August, localized
    case localizedWeekday
    /// No date at all — the label is just the name.
    case none

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dayMonthYear: "Day/Month/Year"
        case .dayMonthShortYear: "Day/Month/Short year"
        case .dayMonth: "Day/Month"
        case .yearMonthDay: "Year-Month-Day"
        case .localizedMedium: "Localized (medium)"
        case .localizedWeekday: "Weekday and date"
        case .none: "No date"
        }
    }

    /// Fixed pattern for the numeric formats; `nil` for the localized ones.
    private var pattern: String? {
        switch self {
        case .dayMonthYear: "dd/MM/yyyy"
        case .dayMonthShortYear: "dd/MM/yy"
        case .dayMonth: "dd/MM"
        case .yearMonthDay: "yyyy-MM-dd"
        case .localizedMedium, .localizedWeekday, .none: nil
        }
    }

    func string(from date: Date, separator: String = " ") -> String {
        switch self {
        case .none:
            return ""
        case .localizedMedium:
            return date.formatted(date: .abbreviated, time: .omitted)
        case .localizedWeekday:
            return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        default:
            guard let pattern else { return "" }
            return DateLabelFormat.formatter(for: pattern).string(from: date)
        }
    }

    /// A live preview of the format using today's date, for the settings screen.
    var sample: String { string(from: .now) }

    private static var cache: [String: DateFormatter] = [:]

    private static func formatter(for pattern: String) -> DateFormatter {
        if let cached = cache[pattern] { return cached }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = pattern
        cache[pattern] = formatter
        return formatter
    }
}

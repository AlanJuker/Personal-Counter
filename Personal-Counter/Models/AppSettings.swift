//
//  AppSettings.swift
//  Personal-Counter
//
//  Every knob the app exposes, persisted in UserDefaults.
//

import Combine
import SwiftUI

/// Density of the counter cards.
enum RowStyle: String, CaseIterable, Identifiable, Codable {
    case compact
    case regular
    case large

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .compact: "Compact"
        case .regular: "Regular"
        case .large: "Large"
        }
    }

    var countFontSize: CGFloat {
        switch self {
        case .compact: 44
        case .regular: 60
        case .large: 76
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .compact: 8
        case .regular: 12
        case .large: 18
        }
    }

    var cardSpacing: CGFloat {
        switch self {
        case .compact: 6
        case .regular: 8
        case .large: 10
        }
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .dark: "Dark"
        case .light: "Light"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .dark: .dark
        case .light: .light
        }
    }
}

enum HapticStrength: String, CaseIterable, Identifiable, Codable {
    case light
    case medium
    case heavy
    case soft
    case rigid

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
}

/// What a tap on the body of a card does.
enum TapAction: String, CaseIterable, Identifiable, Codable {
    case increment
    case decrement
    case nothing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .increment: "Add one step"
        case .decrement: "Subtract one step"
        case .nothing: "Do nothing"
        }
    }
}

@MainActor
final class AppSettings: ObservableObject {

    private enum Key {
        static let defaultCounterName = "defaultCounterName"
        static let includeNameInLabel = "includeNameInLabel"
        static let dateLabelFormat = "dateLabelFormat"
        static let defaultStep = "defaultStep"
        static let defaultGoal = "defaultGoal"
        static let colorAssignment = "colorAssignment"
        static let fixedColor = "fixedColor"
        static let lastAssignedColor = "lastAssignedColor"
        static let lockNewCounters = "lockNewCounters"
        static let allowNegativeByDefault = "allowNegativeByDefault"
        static let plusOpensEditor = "plusOpensEditor"
        static let tapAction = "tapAction"
        static let longPressResets = "longPressResets"
        static let hapticsEnabled = "hapticsEnabled"
        static let hapticStrength = "hapticStrength"
        static let soundEnabled = "soundEnabled"
        static let confirmReset = "confirmReset"
        static let confirmDelete = "confirmDelete"
        static let showSummaryBar = "showSummaryBar"
        static let summaryShowsTotal = "summaryShowsTotal"
        static let summaryShowsAverage = "summaryShowsAverage"
        static let todayBasis = "todayBasis"
        static let sortField = "sortField"
        static let sortAscending = "sortAscending"
        static let rowStyle = "rowStyle"
        static let appearance = "appearance"
        static let showLockBadge = "showLockBadge"
        static let startExpanded = "startExpanded"
    }

    private let defaults: UserDefaults

    // MARK: - New counter defaults

    /// Name prepended to the date, e.g. "Pull ups".
    @Published var defaultCounterName: String { didSet { defaults.set(defaultCounterName, forKey: Key.defaultCounterName) } }
    @Published var includeNameInLabel: Bool { didSet { defaults.set(includeNameInLabel, forKey: Key.includeNameInLabel) } }
    @Published var dateLabelFormat: DateLabelFormat { didSet { defaults.set(dateLabelFormat.rawValue, forKey: Key.dateLabelFormat) } }
    @Published var defaultStep: Int { didSet { defaults.set(defaultStep, forKey: Key.defaultStep) } }
    @Published var defaultGoal: Int { didSet { defaults.set(defaultGoal, forKey: Key.defaultGoal) } }
    @Published var colorAssignment: ColorAssignment { didSet { defaults.set(colorAssignment.rawValue, forKey: Key.colorAssignment) } }
    @Published var fixedColor: CounterColor { didSet { defaults.set(fixedColor.rawValue, forKey: Key.fixedColor) } }
    @Published var lockNewCounters: Bool { didSet { defaults.set(lockNewCounters, forKey: Key.lockNewCounters) } }
    @Published var allowNegativeByDefault: Bool { didSet { defaults.set(allowNegativeByDefault, forKey: Key.allowNegativeByDefault) } }
    @Published var plusOpensEditor: Bool { didSet { defaults.set(plusOpensEditor, forKey: Key.plusOpensEditor) } }

    // MARK: - Interaction

    @Published var tapAction: TapAction { didSet { defaults.set(tapAction.rawValue, forKey: Key.tapAction) } }
    @Published var longPressResets: Bool { didSet { defaults.set(longPressResets, forKey: Key.longPressResets) } }
    @Published var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: Key.hapticsEnabled) } }
    @Published var hapticStrength: HapticStrength { didSet { defaults.set(hapticStrength.rawValue, forKey: Key.hapticStrength) } }
    @Published var soundEnabled: Bool { didSet { defaults.set(soundEnabled, forKey: Key.soundEnabled) } }
    @Published var confirmReset: Bool { didSet { defaults.set(confirmReset, forKey: Key.confirmReset) } }
    @Published var confirmDelete: Bool { didSet { defaults.set(confirmDelete, forKey: Key.confirmDelete) } }

    // MARK: - List presentation

    @Published var showSummaryBar: Bool { didSet { defaults.set(showSummaryBar, forKey: Key.showSummaryBar) } }
    @Published var summaryShowsTotal: Bool { didSet { defaults.set(summaryShowsTotal, forKey: Key.summaryShowsTotal) } }
    @Published var summaryShowsAverage: Bool { didSet { defaults.set(summaryShowsAverage, forKey: Key.summaryShowsAverage) } }
    @Published var todayBasis: TodayBasis { didSet { defaults.set(todayBasis.rawValue, forKey: Key.todayBasis) } }
    @Published var sortField: CounterSortField { didSet { defaults.set(sortField.rawValue, forKey: Key.sortField) } }
    @Published var sortAscending: Bool { didSet { defaults.set(sortAscending, forKey: Key.sortAscending) } }
    @Published var rowStyle: RowStyle { didSet { defaults.set(rowStyle.rawValue, forKey: Key.rowStyle) } }
    @Published var appearance: AppearanceMode { didSet { defaults.set(appearance.rawValue, forKey: Key.appearance) } }
    @Published var showLockBadge: Bool { didSet { defaults.set(showLockBadge, forKey: Key.showLockBadge) } }
    @Published var startExpanded: Bool { didSet { defaults.set(startExpanded, forKey: Key.startExpanded) } }

    /// Remembers the last color handed out so `.cycle` keeps walking the palette.
    var lastAssignedColor: CounterColor {
        get { CounterColor(rawValue: defaults.string(forKey: Key.lastAssignedColor) ?? "") ?? .slate }
        set { defaults.set(newValue.rawValue, forKey: Key.lastAssignedColor) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        func string(_ key: String, _ fallback: String) -> String { defaults.string(forKey: key) ?? fallback }
        func bool(_ key: String, _ fallback: Bool) -> Bool { defaults.object(forKey: key) as? Bool ?? fallback }
        func int(_ key: String, _ fallback: Int) -> Int { defaults.object(forKey: key) as? Int ?? fallback }

        defaultCounterName = string(Key.defaultCounterName, "Counter")
        includeNameInLabel = bool(Key.includeNameInLabel, true)
        dateLabelFormat = DateLabelFormat(rawValue: string(Key.dateLabelFormat, "")) ?? .dayMonthYear
        defaultStep = max(1, int(Key.defaultStep, 1))
        defaultGoal = max(0, int(Key.defaultGoal, 0))
        colorAssignment = ColorAssignment(rawValue: string(Key.colorAssignment, "")) ?? .cycle
        fixedColor = CounterColor(rawValue: string(Key.fixedColor, "")) ?? .emerald
        lockNewCounters = bool(Key.lockNewCounters, false)
        allowNegativeByDefault = bool(Key.allowNegativeByDefault, false)
        plusOpensEditor = bool(Key.plusOpensEditor, false)

        tapAction = TapAction(rawValue: string(Key.tapAction, "")) ?? .increment
        longPressResets = bool(Key.longPressResets, false)
        hapticsEnabled = bool(Key.hapticsEnabled, true)
        hapticStrength = HapticStrength(rawValue: string(Key.hapticStrength, "")) ?? .light
        soundEnabled = bool(Key.soundEnabled, false)
        confirmReset = bool(Key.confirmReset, true)
        confirmDelete = bool(Key.confirmDelete, true)

        showSummaryBar = bool(Key.showSummaryBar, true)
        summaryShowsTotal = bool(Key.summaryShowsTotal, true)
        summaryShowsAverage = bool(Key.summaryShowsAverage, true)
        todayBasis = TodayBasis(rawValue: string(Key.todayBasis, "")) ?? .created
        sortField = CounterSortField(rawValue: string(Key.sortField, "")) ?? .createdAt
        sortAscending = bool(Key.sortAscending, false)
        rowStyle = RowStyle(rawValue: string(Key.rowStyle, "")) ?? .regular
        appearance = AppearanceMode(rawValue: string(Key.appearance, "")) ?? .dark
        showLockBadge = bool(Key.showLockBadge, true)
        startExpanded = bool(Key.startExpanded, false)
    }

    // MARK: - Derived helpers

    /// The label a counter created right now would get, e.g. "Pull ups 13/08/2026".
    func makeLabel(for date: Date = .now) -> String {
        let name = defaultCounterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let datePart = dateLabelFormat.string(from: date)
        guard includeNameInLabel, !name.isEmpty else {
            return datePart.isEmpty ? name : datePart
        }
        return datePart.isEmpty ? name : "\(name) \(datePart)"
    }

    /// Picks the tint for the next counter according to `colorAssignment`.
    func nextColor() -> CounterColor {
        switch colorAssignment {
        case .fixed:
            return fixedColor
        case .random:
            return CounterColor.allCases.randomElement() ?? .emerald
        case .cycle:
            let color = lastAssignedColor.next
            lastAssignedColor = color
            return color
        }
    }

    /// Restores every setting to its shipped default.
    func resetToDefaults() {
        defaultCounterName = "Counter"
        includeNameInLabel = true
        dateLabelFormat = .dayMonthYear
        defaultStep = 1
        defaultGoal = 0
        colorAssignment = .cycle
        fixedColor = .emerald
        lockNewCounters = false
        allowNegativeByDefault = false
        plusOpensEditor = false
        tapAction = .increment
        longPressResets = false
        hapticsEnabled = true
        hapticStrength = .light
        soundEnabled = false
        confirmReset = true
        confirmDelete = true
        showSummaryBar = true
        summaryShowsTotal = true
        summaryShowsAverage = true
        todayBasis = .created
        sortField = .createdAt
        sortAscending = false
        rowStyle = .regular
        appearance = .dark
        showLockBadge = true
        startExpanded = false
    }
}

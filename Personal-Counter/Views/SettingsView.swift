//
//  SettingsView.swift
//  Personal-Counter
//
//  Every parameter of the app in one place.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings

    @Query private var counters: [Counter]
    @Query private var categories: [CounterCategory]

    @State private var confirmingResetAll = false
    @State private var confirmingDeleteAll = false
    @State private var confirmingResetSettings = false

    var body: some View {
        NavigationStack {
            Form {
                categoriesSection
                newCounterSection
                labelSection
                interactionSection
                listSection
                summarySection
                dataSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Reset every counter to zero?", isPresented: $confirmingResetAll) {
                Button("Reset", role: .destructive, action: resetAllCounts)
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete all counters?", isPresented: $confirmingDeleteAll) {
                Button("Delete", role: .destructive, action: deleteAllCounters)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
            .alert("Restore default settings?", isPresented: $confirmingResetSettings) {
                Button("Restore", role: .destructive) { settings.resetToDefaults() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Sections

    private var categoriesSection: some View {
        Section {
            NavigationLink {
                CategoryManagerView()
            } label: {
                HStack {
                    Label("Categories", systemImage: "square.grid.2x2")
                    Spacer()
                    Text("\(categories.count)")
                        .foregroundStyle(.secondary)
                }
            }
            Toggle("Show category filter", isOn: $settings.showCategoryFilter)
            Toggle("Name new counters after the category", isOn: $settings.useCategoryNameInLabel)
            Toggle("Use the category's color", isOn: $settings.useCategoryColor)
            Toggle("Show category symbol on cards", isOn: $settings.showCategoryBadge)
        } header: {
            Text("Categories")
        } footer: {
            Text("With a category selected, “+” creates a counter inside it.")
        }
    }

    private var newCounterSection: some View {
        Section {
            TextField("Name", text: $settings.defaultCounterName)
                .textInputAutocapitalization(.sentences)
            Toggle("Include name in label", isOn: $settings.includeNameInLabel)
            Stepper("Default step: \(settings.defaultStep)", value: $settings.defaultStep, in: 1...1000)
            Stepper(
                settings.defaultGoal > 0 ? "Default goal: \(settings.defaultGoal)" : "Default goal: none",
                value: $settings.defaultGoal,
                in: 0...999_999,
                step: max(1, settings.defaultStep)
            )
            Toggle("Start locked", isOn: $settings.lockNewCounters)
            Toggle("Allow negative values", isOn: $settings.allowNegativeByDefault)
            Toggle("“+” opens the editor", isOn: $settings.plusOpensEditor)
        } header: {
            Text("New counters")
        } footer: {
            Text("A new counter is named “\(settings.makeLabel())”.")
        }
    }

    private var labelSection: some View {
        Section {
            Picker("Date format", selection: $settings.dateLabelFormat) {
                ForEach(DateLabelFormat.allCases) { format in
                    VStack(alignment: .leading) {
                        Text(format.displayName)
                        if !format.sample.isEmpty {
                            Text(format.sample).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .tag(format)
                }
            }

            Picker("Color for new counters", selection: $settings.colorAssignment) {
                ForEach(ColorAssignment.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }

            if settings.colorAssignment == .fixed {
                ColorPickerGrid(selection: $settings.fixedColor)
            }
        } header: {
            Text("Label & color")
        }
    }

    private var interactionSection: some View {
        Section("Interaction") {
            Picker("Tap on a card", selection: $settings.tapAction) {
                ForEach(TapAction.allCases) { action in
                    Text(action.displayName).tag(action)
                }
            }
            Toggle("Long press resets", isOn: $settings.longPressResets)
            Toggle("Haptics", isOn: $settings.hapticsEnabled)
            if settings.hapticsEnabled {
                Picker("Haptic strength", selection: $settings.hapticStrength) {
                    ForEach(HapticStrength.allCases) { strength in
                        Text(strength.displayName).tag(strength)
                    }
                }
            }
            Toggle("Sound", isOn: $settings.soundEnabled)
            Toggle("Confirm before reset", isOn: $settings.confirmReset)
            Toggle("Confirm before delete", isOn: $settings.confirmDelete)
        }
    }

    private var listSection: some View {
        Section("List") {
            Picker("Appearance", selection: $settings.appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            Picker("Card size", selection: $settings.rowStyle) {
                ForEach(RowStyle.allCases) { style in
                    Text(style.displayName).tag(style)
                }
            }
            Picker("Sort by", selection: $settings.sortField) {
                ForEach(CounterSortField.allCases) { field in
                    Label(field.displayName, systemImage: field.symbolName).tag(field)
                }
            }
            Toggle("Ascending order", isOn: $settings.sortAscending)
            Picker("“Today” shows", selection: $settings.todayBasis) {
                ForEach(TodayBasis.allCases) { basis in
                    Text(basis.displayName).tag(basis)
                }
            }
            Toggle("Show lock badge", isOn: $settings.showLockBadge)
            Toggle("Expand cards by default", isOn: $settings.startExpanded)
        }
    }

    private var summarySection: some View {
        Section("Summary bar") {
            Toggle("Show summary bar", isOn: $settings.showSummaryBar)
            if settings.showSummaryBar {
                Toggle("Show total", isOn: $settings.summaryShowsTotal)
                Toggle("Show average", isOn: $settings.summaryShowsAverage)
            }
        }
    }

    private var dataSection: some View {
        Section {
            Button("Reset all counters to zero") { confirmingResetAll = true }
            Button("Restore default settings") { confirmingResetSettings = true }
            Button("Delete all counters", role: .destructive) { confirmingDeleteAll = true }
        } header: {
            Text("Data")
        } footer: {
            Text("\(counters.count) counter\(counters.count == 1 ? "" : "s") stored on this device.")
        }
    }

    // MARK: - Actions

    private func resetAllCounts() {
        for counter in counters {
            counter.reset()
        }
    }

    private func deleteAllCounters() {
        for counter in counters {
            modelContext.delete(counter)
        }
    }
}

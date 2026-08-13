//
//  ContentView.swift
//  Personal-Counter
//
//  Created by Alan Guijarro on 13/8/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings
    @Query private var counters: [Counter]

    @State private var scope: CounterScope = .all
    @State private var editMode: EditMode = .inactive
    /// IDs whose expansion differs from `settings.startExpanded`.
    @State private var toggledIDs: Set<PersistentIdentifier> = []
    @State private var showingSettings = false
    @State private var creatingCounter = false
    @State private var editingCounter: Counter?
    @State private var pendingReset: Counter?
    @State private var pendingDelete: Counter?

    private var visibleCounters: [Counter] {
        CounterOrdering.arrange(
            counters,
            scope: scope,
            todayBasis: settings.todayBasis,
            field: settings.sortField,
            ascending: settings.sortAscending
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            header
            scopePicker
            list
            if settings.showSummaryBar {
                SummaryBar(
                    counters: visibleCounters,
                    showsTotal: settings.summaryShowsTotal,
                    showsAverage: settings.summaryShowsAverage
                )
            }
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingSettings) {
            SettingsView().environmentObject(settings)
        }
        .sheet(isPresented: $creatingCounter) {
            CounterEditorView(mode: .create).environmentObject(settings)
        }
        .sheet(item: $editingCounter) { counter in
            CounterEditorView(mode: .edit(counter)).environmentObject(settings)
        }
        .alert("Reset this counter?", isPresented: resetAlertBinding, presenting: pendingReset) { counter in
            Button("Reset", role: .destructive) { reset(counter) }
            Button("Cancel", role: .cancel) {}
        } message: { counter in
            Text("“\(counter.title)” goes back to zero.")
        }
        .alert("Delete this counter?", isPresented: deleteAlertBinding, presenting: pendingDelete) { counter in
            Button("Delete", role: .destructive) { delete(counter) }
            Button("Cancel", role: .cancel) {}
        } message: { counter in
            Text("“\(counter.title)” will be removed permanently.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            circleButton("plus", label: "New counter", action: addCounter)

            Button {
                withAnimation { editMode = editMode.isEditing ? .inactive : .active }
            } label: {
                Text(editMode.isEditing ? "Done" : "Edit")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .frame(height: 44)
                    .background(controlBackground, in: Capsule())
            }
            .buttonStyle(.plain)

            sortMenu

            Spacer()

            circleButton("gearshape.2", label: "Settings") { showingSettings = true }
        }
        .padding(.horizontal, 12)
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $settings.sortField) {
                ForEach(CounterSortField.allCases) { field in
                    Label(field.displayName, systemImage: field.symbolName).tag(field)
                }
            }
            Divider()
            Picker("Order", selection: $settings.sortAscending) {
                Text("Ascending").tag(true)
                Text("Descending").tag(false)
            }
        } label: {
            Image(systemName: "arrow.up.and.down.text.horizontal")
                .font(.title3.weight(.semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(controlBackground, in: Circle())
        }
        .tint(.primary)
        .accessibilityLabel("Sort")
    }

    private func circleButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(controlBackground, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var controlBackground: some ShapeStyle { Color.primary.opacity(0.12) }

    private var scopePicker: some View {
        Picker("Scope", selection: $scope) {
            ForEach(CounterScope.allCases) { option in
                Text(option.displayName).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 12)
    }

    // MARK: - List

    private var list: some View {
        List {
            ForEach(visibleCounters) { counter in
                CounterRow(
                    counter: counter,
                    style: settings.rowStyle,
                    showLockBadge: settings.showLockBadge,
                    isExpanded: isExpanded(counter),
                    onTap: { handleTap(counter) },
                    onLongPress: { handleLongPress(counter) },
                    onToggleExpanded: { toggleExpanded(counter) },
                    onIncrement: { change(counter, by: counter.step) },
                    onDecrement: { change(counter, by: -counter.step) },
                    onReset: { requestReset(counter) },
                    onToggleLock: { toggleLock(counter) },
                    onEdit: { editingCounter = counter }
                )
                .listRowInsets(EdgeInsets(
                    top: settings.rowStyle.cardSpacing / 2,
                    leading: 12,
                    bottom: settings.rowStyle.cardSpacing / 2,
                    trailing: 12
                ))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing) {
                    if !counter.isLocked {
                        Button(role: .destructive) {
                            requestDelete(counter)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    Button {
                        toggleLock(counter)
                    } label: {
                        Label(counter.isLocked ? "Unlock" : "Lock", systemImage: counter.isLocked ? "lock.open" : "lock")
                    }
                    .tint(.orange)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        requestReset(counter)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .tint(.blue)
                }
            }
            .onMove(perform: move)
            .onDelete(perform: deleteAt)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay {
            if visibleCounters.isEmpty {
                emptyState
            }
        }
        .animation(.snappy, value: visibleCounters.count)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(scope == .today ? "Nothing today" : "No counters yet", systemImage: "number.circle")
        } description: {
            Text(scope == .today
                 ? "Counters you start today show up here."
                 : "Tap + to create “\(settings.makeLabel())”.")
        } actions: {
            Button("New counter", action: addCounter)
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Expansion

    private func isExpanded(_ counter: Counter) -> Bool {
        settings.startExpanded != toggledIDs.contains(counter.persistentModelID)
    }

    private func toggleExpanded(_ counter: Counter) {
        withAnimation(.snappy) {
            let id = counter.persistentModelID
            if toggledIDs.contains(id) {
                toggledIDs.remove(id)
            } else {
                toggledIDs.insert(id)
            }
        }
    }

    // MARK: - Actions

    private func addCounter() {
        guard !settings.plusOpensEditor else {
            creatingCounter = true
            return
        }
        let counter = Counter(
            title: settings.makeLabel(),
            name: settings.defaultCounterName,
            step: settings.defaultStep,
            goal: settings.defaultGoal,
            color: settings.nextColor(),
            isLocked: settings.lockNewCounters,
            allowsNegative: settings.allowNegativeByDefault,
            sortIndex: nextSortIndex()
        )
        withAnimation(.snappy) {
            modelContext.insert(counter)
        }
        Feedback.success(settings: settings)
    }

    private func nextSortIndex() -> Int {
        (counters.map(\.sortIndex).max() ?? 0) + 1
    }

    private func handleTap(_ counter: Counter) {
        guard !editMode.isEditing else { return }
        guard !counter.isLocked else {
            Feedback.warning(settings: settings)
            return
        }
        switch settings.tapAction {
        case .increment: change(counter, by: counter.step)
        case .decrement: change(counter, by: -counter.step)
        case .nothing: break
        }
    }

    private func handleLongPress(_ counter: Counter) {
        guard settings.longPressResets, !editMode.isEditing, !counter.isLocked else { return }
        requestReset(counter)
    }

    /// Applies a delta and fires the matching feedback, including a one-shot
    /// success haptic the moment a goal is reached.
    private func change(_ counter: Counter, by delta: Int) {
        guard !counter.isLocked else {
            Feedback.warning(settings: settings)
            return
        }
        let wasAtGoal = counter.hasReachedGoal
        if delta >= 0 {
            counter.increment(by: delta)
        } else {
            counter.decrement(by: -delta)
        }
        if !wasAtGoal, counter.hasReachedGoal {
            Feedback.success(settings: settings)
        } else {
            Feedback.tap(settings: settings)
        }
    }

    private func toggleLock(_ counter: Counter) {
        counter.isLocked.toggle()
        counter.updatedAt = .now
        Feedback.tap(settings: settings)
    }

    private func requestReset(_ counter: Counter) {
        if settings.confirmReset {
            pendingReset = counter
        } else {
            reset(counter)
        }
    }

    private func reset(_ counter: Counter) {
        withAnimation(.snappy) { counter.reset() }
        Feedback.warning(settings: settings)
    }

    private func requestDelete(_ counter: Counter) {
        if settings.confirmDelete {
            pendingDelete = counter
        } else {
            delete(counter)
        }
    }

    private func delete(_ counter: Counter) {
        withAnimation(.snappy) {
            toggledIDs.remove(counter.persistentModelID)
            modelContext.delete(counter)
        }
    }

    private func deleteAt(_ offsets: IndexSet) {
        let targets = offsets.map { visibleCounters[$0] }.filter { !$0.isLocked }
        guard !targets.isEmpty else { return }
        if settings.confirmDelete, targets.count == 1, let counter = targets.first {
            pendingDelete = counter
        } else {
            withAnimation(.snappy) {
                for counter in targets {
                    toggledIDs.remove(counter.persistentModelID)
                    modelContext.delete(counter)
                }
            }
        }
    }

    /// Dragging a card switches the list to the custom order and renumbers it.
    private func move(from offsets: IndexSet, to destination: Int) {
        var ordered = visibleCounters
        ordered.move(fromOffsets: offsets, toOffset: destination)

        if settings.sortField != .manual {
            settings.sortField = .manual
            settings.sortAscending = true
        }
        for (index, counter) in ordered.enumerated() {
            counter.sortIndex = settings.sortAscending ? index : ordered.count - index
        }
    }

    // MARK: - Alert plumbing

    private var resetAlertBinding: Binding<Bool> {
        Binding(get: { pendingReset != nil }, set: { if !$0 { pendingReset = nil } })
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } })
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings(defaults: UserDefaults(suiteName: "preview") ?? .standard))
        .modelContainer(for: Counter.self, inMemory: true)
        .preferredColorScheme(.dark)
}

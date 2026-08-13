//
//  CounterEditorView.swift
//  Personal-Counter
//
//  Create or edit a single counter.
//

import SwiftData
import SwiftUI

struct CounterEditorView: View {
    enum Mode {
        case create
        case edit(Counter)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings

    @State private var title = ""
    @State private var count = 0
    @State private var step = 1
    @State private var goal = 0
    @State private var color: CounterColor = .emerald
    @State private var isLocked = false
    @State private var allowsNegative = false
    @State private var notes = ""
    @State private var didLoad = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Label") {
                    TextField("Label", text: $title)
                        .textInputAutocapitalization(.sentences)
                    if case .create = mode {
                        Button("Use today's date") {
                            title = settings.makeLabel()
                        }
                        .font(.footnote)
                    }
                }

                Section("Value") {
                    Stepper("Count: \(count)", value: $count, in: allowsNegative ? -999_999...999_999 : 0...999_999)
                    Stepper("Step: \(step)", value: $step, in: 1...1000)
                    Stepper(goal > 0 ? "Goal: \(goal)" : "Goal: none", value: $goal, in: 0...999_999, step: max(1, step))
                    Toggle("Allow negative values", isOn: $allowsNegative)
                }

                Section("Color") {
                    ColorPickerGrid(selection: $color)
                }

                Section("Options") {
                    Toggle("Locked", isOn: $isLocked)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(1...4)
                }
            }
            .navigationTitle(isCreating ? "New Counter" : "Edit Counter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private var isCreating: Bool {
        if case .create = mode { return true }
        return false
    }

    private func load() {
        guard !didLoad else { return }
        didLoad = true

        switch mode {
        case .create:
            title = settings.makeLabel()
            step = settings.defaultStep
            goal = settings.defaultGoal
            color = settings.fixedColor
            isLocked = settings.lockNewCounters
            allowsNegative = settings.allowNegativeByDefault
        case .edit(let counter):
            title = counter.title
            count = counter.count
            step = counter.step
            goal = counter.goal
            color = counter.color
            isLocked = counter.isLocked
            allowsNegative = counter.allowsNegative
            notes = counter.notes
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .create:
            let counter = Counter(
                title: trimmed,
                name: settings.defaultCounterName,
                count: count,
                step: step,
                goal: goal,
                color: color,
                isLocked: isLocked,
                allowsNegative: allowsNegative,
                notes: notes,
                sortIndex: Int(Date.now.timeIntervalSince1970)
            )
            modelContext.insert(counter)
        case .edit(let counter):
            counter.title = trimmed
            counter.count = count
            counter.step = step
            counter.goal = goal
            counter.color = color
            counter.isLocked = isLocked
            counter.allowsNegative = allowsNegative
            counter.notes = notes
            counter.updatedAt = .now
        }

        dismiss()
    }
}

/// A wrapping swatch grid used by both the editor and settings.
struct ColorPickerGrid: View {
    @Binding var selection: CounterColor

    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(CounterColor.allCases) { option in
                Button {
                    selection = option
                } label: {
                    Circle()
                        .fill(option.color)
                        .frame(width: 36, height: 36)
                        .overlay {
                            if option == selection {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(option.foreground)
                            }
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(.primary.opacity(option == selection ? 0.6 : 0), lineWidth: 2)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.displayName)
                .accessibilityAddTraits(option == selection ? [.isSelected] : [])
            }
        }
        .padding(.vertical, 4)
    }
}

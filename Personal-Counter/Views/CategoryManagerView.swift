//
//  CategoryManagerView.swift
//  Personal-Counter
//
//  Create, rename, recolor and reorder counter categories.
//

import SwiftData
import SwiftUI

struct CategoryManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CounterCategory.sortIndex) private var categories: [CounterCategory]

    @State private var editing: CounterCategory?
    @State private var pendingDelete: CounterCategory?

    var body: some View {
        List {
            Section {
                ForEach(categories) { category in
                    Button {
                        editing = category
                    } label: {
                        row(for: category)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: requestDelete)
                .onMove(perform: move)

                Button {
                    addCategory()
                } label: {
                    Label("New category", systemImage: "plus.circle.fill")
                }
            } footer: {
                Text("Deleting a category keeps its counters — they simply become uncategorized.")
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !categories.isEmpty {
                ToolbarItem(placement: .topBarTrailing) { EditButton() }
            }
        }
        .overlay {
            if categories.isEmpty {
                ContentUnavailableView {
                    Label("No categories", systemImage: "square.grid.2x2")
                } description: {
                    Text("Group counters by activity — “Pull ups”, “Cindy Routines”…")
                } actions: {
                    Button("New category", action: addCategory)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .sheet(item: $editing, onDismiss: purgeUnnamed) { category in
            CategoryEditorView(category: category)
        }
        .alert("Delete this category?", isPresented: deleteAlertBinding, presenting: pendingDelete) { category in
            Button("Delete", role: .destructive) { delete(category) }
            Button("Cancel", role: .cancel) {}
        } message: { category in
            Text("“\(category.name)” will be removed. Its \(category.counterCount) counter\(category.counterCount == 1 ? "" : "s") will be kept.")
        }
    }

    private func row(for category: CounterCategory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.symbolName)
                .font(.headline)
                .foregroundStyle(category.color.foreground)
                .frame(width: 34, height: 34)
                .background(category.color.color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .foregroundStyle(.primary)
                Text("\(category.counterCount) counter\(category.counterCount == 1 ? "" : "s") · \(category.total.formatted()) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Actions

    private func addCategory() {
        let category = CounterCategory(
            name: "",
            color: CounterColor.allCases[categories.count % CounterColor.allCases.count],
            sortIndex: (categories.map(\.sortIndex).max() ?? 0) + 1
        )
        modelContext.insert(category)
        editing = category
    }

    private func requestDelete(_ offsets: IndexSet) {
        guard let index = offsets.first else { return }
        pendingDelete = categories[index]
    }

    private func delete(_ category: CounterCategory) {
        modelContext.delete(category)
    }

    /// Swiping the editor away instead of tapping Done would otherwise leave a
    /// nameless category behind.
    private func purgeUnnamed() {
        for category in categories where category.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            modelContext.delete(category)
        }
    }

    private func move(from offsets: IndexSet, to destination: Int) {
        var ordered = categories
        ordered.move(fromOffsets: offsets, toOffset: destination)
        for (index, category) in ordered.enumerated() {
            category.sortIndex = index
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } })
    }
}

/// Name, color and symbol for one category.
struct CategoryEditorView: View {
    @Bindable var category: CounterCategory

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let columns = [GridItem(.adaptive(minimum: 52), spacing: 10)]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Pull ups", text: $category.name)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Color") {
                    ColorPickerGrid(selection: Binding(
                        get: { category.color },
                        set: { category.color = $0 }
                    ))
                }

                Section("Symbol") {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(CategorySymbol.all, id: \.self) { symbol in
                            Button {
                                category.symbolName = symbol
                            } label: {
                                Image(systemName: symbol)
                                    .font(.headline)
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(symbol == category.symbolName ? category.color.foreground : .primary)
                                    .background(
                                        symbol == category.symbolName ? AnyShapeStyle(category.color.color) : AnyShapeStyle(.quaternary),
                                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(symbol)
                            .accessibilityAddTraits(symbol == category.symbolName ? [.isSelected] : [])
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: finish)
                        .disabled(category.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    /// A category that was never given a name is discarded rather than left blank.
    private func finish() {
        category.name = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if category.name.isEmpty {
            modelContext.delete(category)
        }
        dismiss()
    }
}

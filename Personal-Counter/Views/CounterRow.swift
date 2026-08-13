//
//  CounterRow.swift
//  Personal-Counter
//
//  A single tappable counter card.
//

import SwiftUI

struct CounterRow: View {
    @Bindable var counter: Counter
    let style: RowStyle
    let showLockBadge: Bool
    let isExpanded: Bool

    var onTap: () -> Void
    var onLongPress: () -> Void
    var onToggleExpanded: () -> Void
    var onIncrement: () -> Void
    var onDecrement: () -> Void
    var onReset: () -> Void
    var onToggleLock: () -> Void
    var onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if isExpanded {
                Divider()
                    .overlay(counter.color.foreground.opacity(0.35))
                    .padding(.vertical, 10)
                details
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, style.verticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(counter.color.color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onLongPress)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(counter.title), \(counter.count)")
        .accessibilityHint(counter.isLocked ? "Locked" : "Double tap to count")
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if showLockBadge {
                        Image(systemName: counter.isLocked ? "lock.fill" : "lock.open")
                            .font(.subheadline.weight(.semibold))
                            .opacity(counter.isLocked ? 1 : 0.45)
                    }
                    Text(counter.title)
                        .font(.title3.weight(.semibold))
                        .lineLimit(2)
                }

                Button(action: onToggleExpanded) {
                    Image(systemName: "chevron.down")
                        .font(.headline.weight(.semibold))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.trailing, 8)
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Collapse" : "Expand")

                if let progress = counter.progress {
                    ProgressView(value: progress)
                        .tint(counter.color.foreground)
                        .frame(maxWidth: 160)
                }
            }

            Spacer(minLength: 8)

            Text(counter.count.formatted())
                .font(.system(size: style.countFontSize, weight: .light, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .contentTransition(.numericText())
                .animation(.snappy, value: counter.count)
        }
        .foregroundStyle(counter.color.foreground)
    }

    // MARK: - Expanded details

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                circleButton("minus", label: "Subtract \(counter.step)", action: onDecrement)
                circleButton("plus", label: "Add \(counter.step)", action: onIncrement)
                circleButton("arrow.counterclockwise", label: "Reset", action: onReset)
                circleButton(counter.isLocked ? "lock.fill" : "lock.open", label: "Toggle lock", action: onToggleLock)
                circleButton("slider.horizontal.3", label: "Edit", action: onEdit)
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 4) {
                detailLine("Step", "\(counter.step)")
                if counter.goal > 0 {
                    detailLine("Goal", "\(counter.count) / \(counter.goal)")
                }
                detailLine("Created", counter.createdAt.formatted(date: .abbreviated, time: .shortened))
                detailLine("Updated", counter.updatedAt.formatted(date: .abbreviated, time: .shortened))
                if !counter.notes.isEmpty {
                    detailLine("Notes", counter.notes)
                }
            }
        }
        .foregroundStyle(counter.color.foreground)
    }

    private func circleButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .frame(width: 34, height: 34)
                .background(counter.color.foreground.opacity(0.22), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func detailLine(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .opacity(0.75)
            Text(value)
                .font(.caption)
                .opacity(0.95)
        }
    }
}

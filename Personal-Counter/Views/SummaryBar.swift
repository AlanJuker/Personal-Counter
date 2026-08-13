//
//  SummaryBar.swift
//  Personal-Counter
//
//  The floating "Total / Average" pill under the list.
//

import SwiftUI

struct SummaryBar: View {
    let counters: [Counter]
    let showsTotal: Bool
    let showsAverage: Bool

    private var total: Int { counters.reduce(0) { $0 + $1.count } }

    private var average: Double {
        guard !counters.isEmpty else { return 0 }
        return Double(total) / Double(counters.count)
    }

    var body: some View {
        if showsTotal || showsAverage {
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.quaternary.opacity(0.5), in: Capsule())
                .padding(.horizontal, 16)
                .accessibilityLabel(text)
        }
    }

    private var text: String {
        var parts: [String] = []
        if showsTotal {
            parts.append("Total: \(total.formatted())")
        }
        if showsAverage {
            parts.append("Average: \(average.formatted(.number.precision(.fractionLength(0...2))))")
        }
        return parts.joined(separator: " · ")
    }
}

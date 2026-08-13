//
//  Personal_CounterApp.swift
//  Personal-Counter
//
//  Created by Alan Guijarro on 13/8/26.
//

import SwiftData
import SwiftUI

@main
struct Personal_CounterApp: App {
    @StateObject private var settings = AppSettings()
    private let container: ModelContainer

    init() {
        let inMemory = SampleData.isRequested
        do {
            container = try ModelContainer(
                for: Counter.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
            )
        } catch {
            fatalError("Could not create the counter store: \(error)")
        }
        if inMemory {
            SampleData.populate(container.mainContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(settings.appearance.colorScheme)
        }
        .modelContainer(container)
    }
}

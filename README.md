# Personal Counter

A tap-to-count iOS app. Every counter is a card: tap it to add, and each new counter is
labelled with today's date automatically — `Pull ups 13/08/2026`.

Built with SwiftUI + SwiftData, targeting iOS 26.5.

## Features

- **Tap to count.** Tapping a card adds one step; the number animates.
- **Categories.** Group counters by activity — "Pull ups", "Cindy Routines" — each with its
  own color and SF Symbol. Filter the list with the chip row; with a category selected, `+`
  creates a counter inside it, named and colored after it.
- **Auto-dated labels.** A new counter is named `<name> <today's date>` using the format you pick.
- **All / Today.** Filter the list to counters started (or updated) today.
- **Expandable cards.** Tap the chevron for +/−, reset, lock and edit controls, plus created/updated timestamps.
- **Lock.** Locked counters ignore taps and can't be swiped away.
- **Goals.** Give a counter a target and it shows a progress bar plus a haptic when you hit it.
- **Sorting.** By creation date, last update, name, count, or a custom drag-to-reorder order.
- **Summary bar.** Running total and average across whatever the list is showing.
- **Everything is a setting.** See below.

## Settings

| Group | What you can change |
| --- | --- |
| Categories | Manage categories (name, color, symbol, order), show the filter chips, name new counters after the category, use the category's color, show the category symbol on cards |
| New counters | Default name, include name in label, default step, default goal, start locked, allow negatives, whether `+` opens the editor |
| Label & color | Date format (`13/08/2026`, `13/08`, `2026-08-13`, localized, none…), color assignment (cycle / random / fixed), the fixed color |
| Interaction | What a tap does (add / subtract / nothing), long-press to reset, haptics on/off, haptic strength, sound, confirm before reset, confirm before delete |
| List | Appearance (system/dark/light), card size, sort field, sort direction, what "Today" means, lock badge, cards expanded by default |
| Summary bar | Show the bar, show total, show average |
| Data | Reset all counters, restore default settings, delete all counters |

## Project layout

```
Personal-Counter/
├─ Personal_CounterApp.swift     # App entry, SwiftData container
├─ ContentView.swift             # Main list, header, scope picker, actions
├─ Models/
│  ├─ Counter.swift              # @Model: title, count, step, goal, color, lock, category
│  ├─ CounterCategory.swift      # @Model: name, color, symbol, counters
│  ├─ AppSettings.swift          # Every parameter, persisted in UserDefaults
│  ├─ CounterColor.swift         # Card palette
│  ├─ DateLabelFormat.swift      # Date formats for new-counter labels
│  └─ CounterSort.swift          # Scope, category filter + sort ordering
├─ Views/
│  ├─ CounterRow.swift           # The tappable card
│  ├─ CounterEditorView.swift    # Create / edit sheet
│  ├─ CategoryManagerView.swift  # Category list + editor
│  ├─ SettingsView.swift         # Settings form
│  └─ SummaryBar.swift           # Total / average pill
└─ Support/
   ├─ Feedback.swift             # Haptics + sound
   └─ SampleData.swift           # Demo data for previews / -demoData
```

The app icon is generated, not hand-drawn — `Design/MakeIcon.swift` renders the light, dark
and tinted 1024px variants into `Assets.xcassets/AppIcon.appiconset`:

```sh
swift Design/MakeIcon.swift Personal-Counter/Assets.xcassets/AppIcon.appiconset
```

## Running

Open `Personal-Counter.xcodeproj` in Xcode 26 and run on an iOS 26.5 simulator or device.

To launch with throwaway demo data (in-memory store, nothing written to disk):

```sh
xcrun simctl launch <device> Personal.Personal-Counter -demoData
```

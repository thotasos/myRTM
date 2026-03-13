# Design Decisions

## SwiftUI vs AppKit
- **Chosen:** SwiftUI
- **Alternatives considered:** AppKit, UIKit
- **Rationale:** SwiftUI provides modern declarative UI that's optimized for macOS, with better state management through @Binding and @ObservedObject. It's the future of Apple platform development.
- **Tradeoffs:** Less control over some native behaviors, but rapid development and better Swift integration.

## SwiftData vs Core Data
- **Chosen:** SwiftData
- **Alternatives considered:** Core Data, SQLite.swift, UserDefaults
- **Rationale:** SwiftData is Apple's modern replacement for Core Data, with better Swift integration, automatic schema migrations, and native Swift macros (@Model).
- **Tradeoffs:** Requires macOS 14+, but that's acceptable for this project.

## Local-Only Storage
- **Chosen:** Local-only with SwiftData
- **Alternatives considered:** iCloud sync, custom backend, RTM API integration
- **Rationale:** Keep it simple for v1. Focus on core functionality first, add sync later if needed.
- **Tradeoffs:** No cross-device sync, no collaboration features.

## MVVM Architecture
- **Chosen:** MVVM
- **Alternatives considered:** MVC, VIPER, Redux
- **Rationale:** SwiftUI works naturally with MVVM through @Bindable and @Published properties. Simple enough for this app, scales well.
- **Tradeoffs:** Can lead to view model bloat in larger apps, but fine for this scope.

## NavigationSplitView
- **Chosen:** Three-column NavigationSplitView
- **Alternatives considered:** TabView, single window with sheets
- **Rationale:** Classic task manager layout (sidebar + list + detail) matches RTM's UX and is familiar to users.
- **Tradeoffs:** More complex navigation state management.

## Color Palette
- **Chosen:** System colors with custom accent
- **Alternatives considered:** Custom dark theme, light-only
- **Rationale:** Follow macOS design guidelines, respect system appearance (dark/light mode). Use system blue (#007AFF) as primary accent.
- **Tradeoffs:** Less unique branding, but feels native.

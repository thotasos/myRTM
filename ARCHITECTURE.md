# Architecture

## Overview

myRTM follows the MVVM (Model-View-ViewModel) pattern with SwiftUI and SwiftData.

## System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        myRTM App                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │ Sidebar  │───▶│ TaskListView │───▶│TaskDetailView   │  │
│  │  (Nav)   │    │   (List)     │    │  (Inspector)    │  │
│  └──────────┘    └──────────────┘    └─────────────────┘  │
│         │                │                    │             │
│         ▼                ▼                    ▼             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              @Query / SwiftData                     │    │
│  │  ┌──────────┐  ┌────────────┐  ┌────────────┐    │    │
│  │  │ TaskList │  │  TaskItem  │  │    Tag     │    │    │
│  │  └──────────┘  └────────────┘  └────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Components

### Models (SwiftData)
- **TaskItem** — Core task entity with title, notes, dueDate, priority, isCompleted
- **TaskList** — Container for tasks, supports smart lists
- **Tag** — Label entity for cross-categorization

### Views (SwiftUI)
- **ContentView** — Root view with NavigationSplitView
- **SidebarView** — List navigation with smart lists
- **TaskListView** — Main task display with CRUD
- **TaskDetailView** — Task editor with tag management
- **NewTaskSheet / NewListSheet** — Creation dialogs

### Data Flow
1. User interacts with View
2. View calls ViewModel (via @Binding or direct model access)
3. ViewModel updates SwiftData model
4. SwiftData persists to SQLite
5. @Query triggers view refresh

## State Management

- **@Query** — Automatic model fetching from SwiftData
- **@Binding** — Two-way data binding between parent/child views
- **@State** — Local view state (sort order, selection)
- **@Bindable** — Two-way binding for model properties

## Persistence

SwiftData uses SQLite under the hood with automatic schema management. Models are defined using the @Model macro, which generates the necessary schema.

## Extension Points

- **Smart Lists** — Filter predicates can be extended for more filters
- **Keyboard Shortcuts** — Add more in myRTMApp.commands
- **Sync** — ModelContainer can be configured for iCloud

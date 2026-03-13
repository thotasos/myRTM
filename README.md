# myRTM

A premium minimalist Remember The Milk-style task manager for macOS.

![myRTM Screenshot](https://via.placeholder.com/800x600?text=myRTM)

## Features

- **Lists & Tasks** — Organize tasks into custom lists with color-coded categories
- **Smart Lists** — Built-in filters for Today, Overdue, Completed, and All Tasks
- **Tags** — Add multiple tags to tasks for cross-categorization
- **Due Dates & Times** — Set deadlines with optional time reminders
- **Priority Levels** — Four priority levels with visual indicators (Highest, High, Low, None)
- **Keyboard Shortcuts** — Power-user workflow with Cmd+N, Cmd+Enter, and more
- **Premium Minimalist Design** — Clean, distraction-free interface following macOS design guidelines

## Tech Stack

- **SwiftUI** — Native Apple UI framework
- **SwiftData** — Local persistence (SQLite)
- **MVVM Architecture** — Clean separation of concerns

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/thotas/myRTM.git
   cd myRTM
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open in Xcode:
   ```bash
   open myRTM.xcodeproj
   ```

4. Build and run (Cmd+R)

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd+N | New task |
| Cmd+Shift+N | New list |
| Cmd+Enter | Complete task |
| Cmd+1 | Priority 1 (Highest) |
| Cmd+2 | Priority 2 (High) |
| Cmd+3 | Priority 3 (Low) |
| Cmd+4 | Priority 4 (None) |
| Cmd+T | Add tag |
| Cmd+Shift+T | New tag |
| Cmd+D | Set due date |
| Cmd+Backspace | Delete task |

## Architecture

```
myRTM/
├── Models/
│   ├── TaskItem.swift      # Task data model
│   ├── TaskList.swift      # List data model
│   └── Tag.swift           # Tag data model
├── Views/
│   ├── ContentView.swift   # Main split view
│   ├── SidebarView.swift   # Lists sidebar
│   ├── TaskListView.swift  # Task list
│   ├── TaskDetailView.swift # Task detail inspector
│   └── NewTaskSheet.swift  # Task/list creation sheets
├── Extensions/
│   └── Color+Hex.swift    # Hex color support
├── myRTMApp.swift         # App entry point
└── Resources/
    └── Assets.xcassets    # App icons
```

## Known Limitations

- No cloud sync (local-only storage)
- No notifications (yet)
- No subtasks
- No recurring tasks

## Roadmap

- [ ] iCloud sync
- [ ] Notifications
- [ ] Subtasks
- [ ] Recurring tasks
- [ ] Menu bar widget

## License

MIT License

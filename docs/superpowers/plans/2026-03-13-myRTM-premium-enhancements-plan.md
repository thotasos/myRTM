# myRTM Premium Enhancements Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement four enhancement categories for myRTM: documentation updates, search functionality, missing keyboard shortcuts, and premium UI/UX polish.

**Architecture:** Incremental feature additions following existing MVVM pattern with SwiftUI/SwiftData. Each enhancement is self-contained and testable.

**Tech Stack:** SwiftUI, SwiftData, XCTest

---

## File Structure

| File | Responsibility |
|------|----------------|
| `README.md` | Update documentation |
| `myRTM/myRTMApp.swift` | Add keyboard shortcuts |
| `myRTM/Views/ContentView.swift` | Wire search text |
| `myRTM/Views/TaskListView.swift` | Add search bar and filtering |
| `myRTM/Views/TaskDetailView.swift` | Keyboard shortcut support for tags/dates |
| `myRTM/Views/SidebarView.swift` | Minor polish |
| `myRTMTests/*.swift` | Add view tests |

---

## Chunk 1: Documentation Updates

### Task 1.1: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update Known Limitations**

Remove the "No notifications (yet)" line from Known Limitations section since notifications are already implemented.

- [ ] **Step 2: Update Roadmap**

Mark Notifications as complete in the roadmap checklist.

- [ ] **Step 3: Verify Keyboard Shortcuts Section**

Check that the documented shortcuts match what's actually implemented in the app.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: update README - mark notifications complete"
```

---

## Chunk 2: Search Functionality

### Task 2.1: Add Search to TaskListView

**Files:**
- Modify: `myRTM/Views/TaskListView.swift`

- [ ] **Step 1: Add searchText parameter to TaskListView**

```swift
// In TaskListView struct, add:
@Binding var searchText: String
```

- [ ] **Step 2: Update filteredTasks to include search**

```swift
// In var filteredTasks, add search filter:
var filteredTasks: [TaskItem] {
    guard let list = selectedList else { return [] }

    var tasks: [TaskItem]

    if list.isSmartList {
        switch list.smartListType {
        case .today:
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            tasks = allTasks.filter { !$0.isCompleted && ($0.dueDate ?? .distantPast) >= startOfDay && ($0.dueDate ?? .distantFuture) < endOfDay }
        case .overdue:
            let today = Calendar.current.startOfDay(for: Date())
            tasks = allTasks.filter { !$0.isCompleted && ($0.dueDate ?? .distantFuture) < today }
        case .completed:
            tasks = allTasks.filter { $0.isCompleted }
        case .all, .none:
            tasks = allTasks.filter { !$0.isCompleted }
        }
    } else {
        tasks = allTasks.filter { $0.taskList?.id == list.id && !$0.isCompleted }
    }

    // Apply search filter
    if !searchText.isEmpty {
        tasks = tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
            task.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    return tasks
}
```

- [ ] **Step 3: Add search bar to toolbar with icon and clear button**

In the header HStack, add:

```swift
HStack {
    Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)

    TextField("Search tasks...", text: $searchText)
        .textFieldStyle(.plain)
        .frame(width: 150)

    if !searchText.isEmpty {
        Button(action: { searchText = "" }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 4: Add search debounce (150ms)**

Add debounce state to prevent filtering on every keystroke:

```swift
@State private var debouncedSearchText = ""
@State private var searchDebounceTimer: Timer?

// After searchText changes:
.onChange(of: searchText) { _, newValue in
    searchDebounceTimer?.invalidate()
    searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
        debouncedSearchText = newValue
    }
}

// Use debouncedSearchText in filteredTasks
```

- [ ] **Step 4: Commit**

```bash
git add myRTM/Views/TaskListView.swift
git commit -m "feat: add search functionality to task list"
```

### Task 2.2: Wire SearchText in ContentView

**Files:**
- Modify: `myRTM/Views/ContentView.swift`

- [ ] **Step 1: Add searchText state**

```swift
@State private var searchText = ""
```

- [ ] **Step 2: Pass searchText to TaskListView**

```swift
// In TaskListView instantiation:
TaskListView(
    selectedList: selectedList,
    selectedTask: $selectedTask,
    allTags: allTags,
    showingNewTask: $showingNewTask,
    searchText: $searchText  // Add this
)
```

- [ ] **Step 3: Commit**

```bash
git add myRTM/Views/ContentView.swift
git commit -m "feat: wire search text to task list view"
```

---

## Chunk 3: Keyboard Shortcuts

### Task 3.1: Add Priority Shortcuts (Cmd+1-4)

**Files:**
- Modify: `myRTM/myRTMApp.swift`

- [ ] **Step 1: Add priority shortcut commands**

In the `.commands` block, add:

```swift
CommandGroup(after: .newItem) {
    Divider()

    Button("Priority 1 (Highest)") {
        NotificationCenter.default.post(name: .setPriority, object: 1)
    }
    .keyboardShortcut("1", modifiers: .command)

    Button("Priority 2 (High)") {
        NotificationCenter.default.post(name: .setPriority, object: 2)
    }
    .keyboardShortcut("2", modifiers: .command)

    Button("Priority 3 (Low)") {
        NotificationCenter.default.post(name: .setPriority, object: 3)
    }
    .keyboardShortcut("3", modifiers: .command)

    Button("Priority 4 (None)") {
        NotificationCenter.default.post(name: .setPriority, object: 4)
    }
    .keyboardShortcut("4", modifiers: .command)
}
```

- [ ] **Step 2: Add notification name extension**

```swift
extension Notification.Name {
    static let newTask = Notification.Name("newTask")
    static let newList = Notification.Name("newList")
    static let setPriority = Notification.Name("setPriority")  // Add this
}
```

- [ ] **Step 3: Handle priority shortcuts in TaskListView with edge case handling**

Add `@StateObject` or listen to notification in TaskListView to apply priority to selected task.

**Important: Add edge case handling**

```swift
.onReceive(NotificationCenter.default.publisher(for: .setPriority)) { notification in
    guard let priority = notification.object as? Int,
          let task = selectedTask else {
        // No task selected - optionally show alert
        return
    }
    task.priority = priority
}
```

The shortcut buttons should be disabled when no task is selected:

```swift
Button("Priority 1 (Highest)") {
    NotificationCenter.default.post(name: .setPriority, object: 1)
}
.keyboardShortcut("1", modifiers: .command)
.disabled(selectedTask == nil)  // Requires @Query or passed state
```

- [ ] **Step 4: Commit**

```bash
git add myRTM/myRTMApp.swift myRTM/Views/TaskListView.swift
git commit -m "feat: add priority keyboard shortcuts (Cmd+1-4)"
```

### Task 3.2: Add Tag and Date Shortcuts

**Files:**
- Modify: `myRTM/myRTMApp.swift`, `myRTM/Views/TaskDetailView.swift`

- [ ] **Step 1: Add Cmd+T and Cmd+Shift+T shortcuts**

```swift
Button("Add Tag") {
    NotificationCenter.default.post(name: .addTag, object: nil)
}
.keyboardShortcut("t", modifiers: .command)

Button("New Tag") {
    NotificationCenter.default.post(name: .newTag, object: nil)
}
.keyboardShortcut("t", modifiers: [.command, .shift])
```

- [ ] **Step 2: Add Cmd+D shortcut for due date**

```swift
Button("Set Due Date") {
    NotificationCenter.default.post(name: .focusDueDate, object: nil)
}
.keyboardShortcut("d", modifiers: .command)
```

- [ ] **Step 3: Add notification names**

```swift
static let addTag = Notification.Name("addTag")
static let newTag = Notification.Name("newTag")
static let focusDueDate = Notification.Name("focusDueDate")
```

- [ ] **Step 4: Handle in TaskDetailView**

Add `.onReceive` to show tag picker or focus due date field.

- [ ] **Step 5: Commit**

```bash
git add myRTM/myRTMApp.swift myRTM/Views/TaskDetailView.swift
git commit -m "feat: add tag and due date keyboard shortcuts"
```

### Task 3.3: Add Delete Confirmation

**Files:**
- Modify: `myRTM/myRTMApp.swift`, `myRTM/Views/TaskListView.swift`

- [ ] **Step 1: Add Cmd+Backspace shortcut**

```swift
Button("Delete Task") {
    NotificationCenter.default.post(name: .deleteTask, object: nil)
}
.keyboardShortcut(.delete, modifiers: .command)
```

- [ ] **Step 2: Add notification name and handling**

Add confirmation dialog in TaskListView when deleting non-empty tasks.

- [ ] **Step 3: Commit**

```bash
git add myRTM/myRTMApp.swift myRTM/Views/TaskListView.swift
git commit -m "feat: add delete task shortcut with confirmation"
```

---

## Chunk 4: Premium UI/UX Polish

### Task 4.1: Add Animations

**Files:**
- Modify: `myRTM/Views/TaskListView.swift`, `myRTM/Views/TaskDetailView.swift`

- [ ] **Step 1: Add task completion animation**

In TaskRowView, wrap the checkbox in an animation:

```swift
Button(action: onToggleComplete) {
    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
        .font(.system(size: 18))
        .foregroundStyle(task.isCompleted ? Color.green : .secondary)
        .symbolEffect(.bounce, value: task.isCompleted)  // Requires macOS 14+
}
.buttonStyle(.plain)
```

- [ ] **Step 1b: Add strikethrough animation**

```swift
Text(task.title.isEmpty ? "New Task" : task.title)
    .font(.body)
    .foregroundStyle(task.isCompleted ? .secondary : .primary)
    .strikethrough(task.isCompleted, pattern: .solid, color: .secondary)
    .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
```

- [ ] **Step 2: Add hover effect to task rows**

```swift
@State private var isHovered = false

// In the HStack:
.background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
.animation(.easeInOut(duration: 0.2), value: isHovered)
.onHover { hovering in
    isHovered = hovering
}
```

- [ ] **Step 3: Add sheet spring animation**

In ContentView, add animation to sheets using `.transaction`:

```swift
.sheet(isPresented: $showingNewTask) {
    NewTaskSheet(selectedList: selectedList, isPresented: $showingNewTask)
        .transaction { t in
            t.animation = .spring(response: 0.3, dampingFraction: 0.8)
        }
}
```

Or simply use the default sheet animation by wrapping in withAnimation:

```swift
// In the button that shows the sheet:
withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
    showingNewTask = true
}
```

- [ ] **Step 4: Commit**

```bash
git add myRTM/Views/TaskListView.swift
git commit -m "feat: add animations - completion, hover, sheets"
```

### Task 4.2: Typography Updates

**Files:**
- Modify: `myRTM/Views/TaskListView.swift`, `myRTM/Views/TaskDetailView.swift`

- [ ] **Step 1: Update task title font**

In TaskRowView, change:

```swift
Text(task.title.isEmpty ? "New Task" : task.title)
    .font(.body)  // Change to .body.weight(.medium)
```

- [ ] **Step 2: Update caption font**

```swift
Text(dueDate, style: .relative)
    .font(.caption)  // Change to .caption.weight(.medium)
```

- [ ] **Step 3: Update row padding**

```swift
// In listRowInsets:
padding(.vertical, 4)  // Change to padding(.vertical, 8)
```

- [ ] **Step 4: Commit**

```bash
git add myRTM/Views/TaskListView.swift myRTM/Views/TaskDetailView.swift
git commit -m "feat: update typography - fonts, weights, spacing"
```

### Task 4.3: Enhanced Empty States

**Files:**
- Modify: `myRTM/Views/TaskListView.swift`

- [ ] **Step 1: Add contextual empty states**

Replace generic empty state with context-aware versions:

```swift
if sortedTasks.isEmpty {
    VStack(spacing: 16) {
        Image(systemName: emptyStateIcon)
            .font(.system(size: 48))
            .foregroundStyle(.secondary)

        Text(emptyStateTitle)
            .font(.headline)
            .foregroundStyle(.secondary)

        Text(emptyStateSubtitle)
            .font(.subheadline)
            .foregroundStyle(.tertiary)

        if selectedList?.isSmartList == false {
            Button("Add Task") {
                showingNewTask = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(hex: "#F5F5F7"), Color(hex: "#FFFFFF")],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
```

- [ ] **Step 2: Add computed properties for empty state**

```swift
var emptyStateIcon: String {
    guard let list = selectedList else { return "checkmark.circle" }
    switch list.smartListType {
    case .completed: return "checkmark.circle"
    case .today: return "calendar"
    case .overdue: return "exclamationmark.triangle"
    default: return "checkmark.circle"
    }
}

var emptyStateTitle: String {
    guard let list = selectedList else { return "No tasks" }
    switch list.smartListType {
    case .completed: return "All caught up!"
    case .overdue: return "No overdue tasks"
    default: return "No tasks"
    }
}

var emptyStateSubtitle: String {
    guard let list = selectedList else { return "Press ⌘N to add a task" }
    switch list.smartListType {
    case .completed: return "Completed tasks will appear here"
    case .today: return "You have no tasks due today"
    case .overdue: return "Great job staying on top of things!"
    default: return "Press ⌘N to add a task"
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add myRTM/Views/TaskListView.swift
git commit -m "feat: add contextual empty states with gradient"
```

### Task 4.4: Selected Row Polish

**Files:**
- Modify: `myRTM/Views/TaskListView.swift`

- [ ] **Step 1: Improve selected row styling**

In TaskRowView, enhance selected state:

```swift
// Add selection indicator
RoundedRectangle(cornerRadius: 4)
    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    .padding(.horizontal, -4)
```

- [ ] **Step 2: Commit**

```bash
git add myRTM/Views/TaskListView.swift
git commit -m "feat: improve selected row visual indicator"
```

### Task 4.5: Sidebar Polish

**Files:**
- Modify: `myRTM/Views/SidebarView.swift`

- [ ] **Step 1: Add sidebar collapse animation**

The NavigationSplitView handles this automatically with `.animation()`:

```swift
.navigationSplitView(columnVisibility: $columnVisibility)
.animation(.easeInOut(duration: 0.25), value: columnVisibility)
```

- [ ] **Step 2: Add focus state indicators**

Add keyboard focus ring visibility:

```swift
// In SidebarView, ensure buttons have focus states
Button(action: { showingNewList = true }) {
    Image(systemName: "plus")
}
.buttonStyle(.borderlessButton)
.help("New List")
```

- [ ] **Step 3: Commit**

```bash
git add myRTM/Views/SidebarView.swift
git commit -m "feat: add sidebar polish - animations and focus states"
```

### Task 4.6: Tag Pill Contrast Improvement

**Files:**
- Modify: `myRTM/Views/TaskDetailView.swift`, `myRTM/Views/TaskListView.swift`

- [ ] **Step 1: Improve tag pill contrast**

Update tag pill styling with better color contrast:

```swift
// In TaskDetailView and TaskRowView:
Text(tag.name)
    .font(.caption.weight(.medium))  // Add medium weight
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Color(hex: tag.color).opacity(0.15))
    .foregroundStyle(Color(hex: tag.color).opacity(0.9))  // Darker text
    .clipShape(Capsule())
```

- [ ] **Step 2: Commit**

```bash
git add myRTM/Views/TaskDetailView.swift myRTM/Views/TaskListView.swift
git commit -m "feat: improve tag pill contrast and readability"
```

---

## Chunk 5: Testing

### Task 5.1: Add View Tests

**Files:**
- Modify: `myRTMTests/`

- [ ] **Step 1: Add TaskListView tests**

Create tests for:
- Search filtering
- Empty state display
- Task row rendering

- [ ] **Step 2: Run tests**

```bash
xcodebuild test -project myRTM.xcodeproj -scheme myRTM -destination 'platform=macOS'
```

- [ ] **Step 3: Commit**

```bash
git add myRTMTests/
git commit -m "test: add view tests for search and empty states"
```

---

## Final Steps

### Task 6.1: Final Build Verification

- [ ] **Run full build**

```bash
xcodebuild -project myRTM.xcodeproj -scheme myRTM -configuration Debug build
```

- [ ] **Run all tests**

```bash
xcodebuild test -project myRTM.xcodeproj -scheme myRTM -destination 'platform=macOS'
```

- [ ] **Commit final changes**

```bash
git add -A
git commit -m "feat: implement premium enhancements

- Add search functionality
- Implement keyboard shortcuts (Cmd+1-4, Cmd+T, Cmd+D, etc.)
- Add premium UI polish (animations, typography, empty states)
- Update documentation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Summary

| Chunk | Tasks | Description |
|-------|-------|-------------|
| 1 | 1 | Documentation updates |
| 2 | 2 | Search functionality |
| 3 | 3 | Keyboard shortcuts |
| 4 | 6 | Premium UI/UX polish |
| 5 | 1 | Testing |
| 6 | 1 | Final verification |

Total: 14 tasks across 6 chunks.

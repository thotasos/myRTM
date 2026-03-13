# myRTM Premium Enhancements Design

**Date:** 2026-03-13
**Status:** Approved

## Overview

This spec covers four enhancement categories for myRTM:
1. Documentation updates
2. Search functionality
3. Missing keyboard shortcuts
4. Premium UI/UX polish

---

## 1. Documentation Updates

### Changes to README.md

**Remove from Known Limitations:**
- "No notifications (yet)" - Already implemented in NotificationManager.swift

**Update Roadmap:**
- [x] Notifications - Mark as complete
- [ ] iCloud sync
- [ ] Subtasks
- [ ] Recurring tasks
- [ ] Menu bar widget

**Add Keyboard Shortcuts Section:**
- Document all implemented shortcuts matching actual app behavior

---

## 2. Search Functionality

### Architecture

**Components Modified:**
- `ContentView.swift` - Already has `searchText` state, wire to filter
- `TaskListView.swift` - Add search bar and filtering logic

### Data Flow

```
User types in search field
    → ContentView.searchText updates
    → Passed to TaskListView
    → filteredTasks applies search filter
    → View updates with filtered results
```

### Behavior

- **Real-time filtering** as user types (debounce 150ms)
- **Search scope:** task title and notes fields
- **Empty search:** returns all tasks matching current list filter
- **Search persists:** Search text is preserved when switching between lists, applied to new list's tasks

### UI Specification

- Search field in toolbar of TaskListView
- Magnifying glass icon
- Clear button when text present
- Placeholder: "Search tasks..."

---

## 3. Keyboard Shortcuts

### Implementation

Add to `myRTMApp.commands`:

| Shortcut | Action | Conditions |
|----------|--------|------------|
| Cmd+N | New task | Always available |
| Cmd+Enter | Toggle task completion | Task selected |
| Cmd+1 | Set priority to 1 (Highest) | Task selected |
| Cmd+2 | Set priority to 2 (High) | Task selected |
| Cmd+3 | Set priority to 3 (Low) | Task selected |
| Cmd+4 | Set priority to 4 (None) | Task selected |
| Cmd+T | Show tag picker popover | Task selected |
| Cmd+Shift+T | Create new tag | Task selected |
| Cmd+D | Focus due date picker | Task detail open |
| Cmd+Backspace | Delete task | Task selected, show confirmation |

### Edge Cases

- **No task selected:** Shortcuts disabled or show alert
- **Confirm delete:** Alert for tasks with title, no confirmation for empty tasks
- **Priority shortcuts:** Work in both list view and detail view

---

## 4. Premium UI/UX Polish

### Animations

**Task Completion:**
- Checkbox: scale 1.0 → 1.2 → 1.0 (150ms)
- Checkmark fade-in (100ms)
- Task row strikethrough animation

**List Interactions:**
- Row hover: background opacity transition (200ms ease-in-out)
- List item insertion: slide from top (250ms spring)

**Sheets:**
- New task/list sheets: spring animation (response: 0.3, dampingFraction: 0.8)

**Deletion:**
- Task row slides out left (200ms)
- List refreshes after animation completes

### Typography

**Font Adjustments:**
- Task titles in list view: 14pt → 15pt semibold
- Body text: 14pt → 15pt
- Captions: 11pt → 12pt
- Section headers: medium weight

**Spacing:**
- List row padding: 8pt vertical → 12pt
- Inter-element spacing: 8pt → 12pt

### Empty States

**Completed List:**
- Large checkmark circle icon (48pt)
- "All caught up!" heading
- "No completed tasks" subtext

**Today/Overdue:**
- Calendar icon for today
- Warning icon for overdue
- Contextual subtext

**User Lists (empty):**
- "No tasks yet" heading
- "Press ⌘N to add a task" subtext
- Subtle gradient background (#F5F5F7 to #FFFFFF)

### Additional Polish

- **Sidebar:** Smooth collapse animation (250ms)
- **Selected row:** Subtle highlight (#007AFF at 10% opacity)
- **Tag pills:** Improved contrast, darker text on light backgrounds
- **Focus states:** Visible keyboard navigation indicators

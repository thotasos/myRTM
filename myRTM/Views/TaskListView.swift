import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext

    let selectedList: TaskList?
    @Binding var selectedTask: TaskItem?
    let allTags: [Tag]
    @Binding var showingNewTask: Bool
    @Binding var searchText: String

    @State private var sortOrder = TaskSortOrder.priority
    @State private var editingTaskId: UUID?
    @State private var debouncedSearchText = ""
    @State private var searchDebounceTimer: Timer?
    @State private var showingDeleteConfirmation = false

    @Query private var allTasks: [TaskItem]

    init(selectedList: TaskList?, selectedTask: Binding<TaskItem?>, allTags: [Tag], showingNewTask: Binding<Bool>, searchText: Binding<String>) {
        self.selectedList = selectedList
        self._selectedTask = selectedTask
        self.allTags = allTags
        self._showingNewTask = showingNewTask
        self._searchText = searchText

        var descriptor = FetchDescriptor<TaskItem>()
        descriptor.sortBy = [SortDescriptor(\.priority), SortDescriptor(\.createdAt, order: .reverse)]
        _allTasks = Query(descriptor)
    }

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
        if !debouncedSearchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(debouncedSearchText) ||
                task.notes.localizedCaseInsensitiveContains(debouncedSearchText)
            }
        }

        return tasks
    }

    var sortedTasks: [TaskItem] {
        switch sortOrder {
        case .priority:
            return filteredTasks.sorted { $0.priority < $1.priority }
        case .dueDate:
            return filteredTasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .createdAt:
            return filteredTasks.sorted { $0.createdAt > $1.createdAt }
        }
    }

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

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(selectedList?.name ?? "Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

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

                Menu {
                    Button("Priority") { sortOrder = .priority }
                    Button("Due Date") { sortOrder = .dueDate }
                    Button("Created Date") { sortOrder = .createdAt }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)

                Button(action: { showingNewTask = true }) {
                    Image(systemName: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .onChange(of: searchText) { _, newValue in
                searchDebounceTimer?.invalidate()
                searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    debouncedSearchText = newValue
                }
            }

            Divider()

            // Task List
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(nsColor: .controlBackgroundColor).opacity(0.5), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            } else {
                List(sortedTasks, selection: $selectedTask) { task in
                    TaskRowView(
                        task: task,
                        isSelected: selectedTask?.id == task.id,
                        onToggleComplete: { toggleComplete(task) },
                        onDelete: { deleteTask(task) }
                    )
                    .tag(task)
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                }
                .listStyle(.plain)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .setPriority)) { notification in
            guard let priority = notification.object as? Int,
                  let task = selectedTask else {
                return
            }
            task.priority = priority
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteTask)) { _ in
            guard let task = selectedTask else { return }
            if !task.title.isEmpty {
                showingDeleteConfirmation = true
            } else {
                deleteTask(task)
            }
        }
        .alert("Delete Task?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let task = selectedTask {
                    deleteTask(task)
                }
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
    }

    private func toggleComplete(_ task: TaskItem) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
    }

    private func deleteTask(_ task: TaskItem) {
        if selectedTask?.id == task.id {
            selectedTask = nil
        }
        modelContext.delete(task)
    }
}

enum TaskSortOrder {
    case priority, dueDate, createdAt
}

struct TaskRowView: View {
    @Bindable var task: TaskItem
    let isSelected: Bool
    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)

            // Checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(task.isCompleted ? Color.green : .secondary)
                    .symbolEffect(.bounce, value: task.isCompleted)
            }
            .buttonStyle(.plain)

            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title.isEmpty ? "New Task" : task.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, pattern: .solid, color: .secondary)
                    .animation(.easeInOut(duration: 0.2), value: task.isCompleted)

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .relative)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(dueDate < Date() ? .red : .secondary)
                }
            }

            Spacer()

            // Tags
            if !task.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(task.tags.prefix(3)) { tag in
                        Text(tag.name)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: tag.color).opacity(0.15))
                            .foregroundStyle(Color(hex: tag.color).opacity(0.9))
                            .clipShape(Capsule())
                    }
                }
            }

            // Actions (visible on hover)
            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                .padding(.horizontal, -4)
        )
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }

    var priorityColor: Color {
        switch task.priority {
        case 1: return Color(hex: "#FF3B30")
        case 2: return Color(hex: "#FF9500")
        case 3: return Color(hex: "#FFCC00")
        default: return Color(hex: "#8E8E93")
        }
    }
}

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext

    let selectedList: TaskList?
    @Binding var selectedTask: TaskItem?
    let allTags: [Tag]
    @Binding var showingNewTask: Bool

    @State private var sortOrder = TaskSortOrder.priority
    @State private var editingTaskId: UUID?

    @Query private var allTasks: [TaskItem]

    init(selectedList: TaskList?, selectedTask: Binding<TaskItem?>, allTags: [Tag], showingNewTask: Binding<Bool>) {
        self.selectedList = selectedList
        self._selectedTask = selectedTask
        self.allTags = allTags
        self._showingNewTask = showingNewTask

        var descriptor = FetchDescriptor<TaskItem>()
        descriptor.sortBy = [SortDescriptor(\.priority), SortDescriptor(\.createdAt, order: .reverse)]
        _allTasks = Query(descriptor)
    }

    var filteredTasks: [TaskItem] {
        guard let list = selectedList else { return [] }

        if list.isSmartList {
            switch list.smartListType {
            case .today:
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: Date())
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                return allTasks.filter { !$0.isCompleted && ($0.dueDate ?? .distantPast) >= startOfDay && ($0.dueDate ?? .distantFuture) < endOfDay }
            case .overdue:
                let today = Calendar.current.startOfDay(for: Date())
                return allTasks.filter { !$0.isCompleted && ($0.dueDate ?? .distantFuture) < today }
            case .completed:
                return allTasks.filter { $0.isCompleted }
            case .all, .none:
                return allTasks.filter { !$0.isCompleted }
            }
        } else {
            return allTasks.filter { $0.taskList?.id == list.id && !$0.isCompleted }
        }
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

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(selectedList?.name ?? "Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

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

            Divider()

            // Task List
            if sortedTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No tasks")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Press ⌘N to add a task")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(sortedTasks, selection: $selectedTask) { task in
                    TaskRowView(
                        task: task,
                        isSelected: selectedTask?.id == task.id,
                        onToggleComplete: { toggleComplete(task) },
                        onDelete: { deleteTask(task) }
                    )
                    .tag(task)
                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                }
                .listStyle(.plain)
            }
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
            }
            .buttonStyle(.plain)

            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title.isEmpty ? "New Task" : task.title)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .relative)
                        .font(.caption)
                        .foregroundStyle(dueDate < Date() ? .red : .secondary)
                }
            }

            Spacer()

            // Tags
            if !task.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(task.tags.prefix(3)) { tag in
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: tag.color).opacity(0.2))
                            .foregroundStyle(Color(hex: tag.color))
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

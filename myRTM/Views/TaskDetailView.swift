import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: TaskItem
    let allTags: [Tag]

    @State private var showingTagPicker = false
    @State private var newTagName = ""
    @State private var newTagColor = "#007AFF"

    var body: some View {
        Form {
            Section {
                TextField("Task title", text: $task.title)
                    .textFieldStyle(.plain)
                    .font(.headline)
            }

            Section("Notes") {
                TextEditor(text: $task.notes)
                    .frame(minHeight: 80)
                    .font(.body)
            }

            Section("Details") {
                // Priority
                HStack {
                    Text("Priority")
                    Spacer()
                    Picker("Priority", selection: $task.priority) {
                        Text("Highest").tag(1)
                        Text("High").tag(2)
                        Text("Low").tag(3)
                        Text("None").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }

                // Due Date
                HStack {
                    Text("Due Date")
                    Spacer()
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { task.dueDate ?? Date() },
                            set: { newDate in
                                task.dueDate = newDate
                                NotificationManager.shared.updateNotification(for: task)
                            }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.field)
                    .labelsHidden()

                    if task.dueDate != nil {
                        Button(action: {
                            task.dueDate = nil
                            NotificationManager.shared.cancelNotification(for: task)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // List
                if let list = task.taskList {
                    HStack {
                        Text("List")
                        Spacer()
                        Text(list.name)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Tags") {
                FlowLayout(spacing: 6) {
                    ForEach(task.tags) { tag in
                        HStack(spacing: 4) {
                            Text(tag.name)
                            Button(action: { removeTag(tag) }) {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: tag.color).opacity(0.2))
                        .foregroundStyle(Color(hex: tag.color))
                        .clipShape(Capsule())
                    }

                    Button(action: { showingTagPicker.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add Tag")
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundStyle(.secondary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if showingTagPicker {
                Section("New Tag") {
                    HStack {
                        TextField("Tag name", text: $newTagName)
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: newTagColor) },
                            set: { newTagColor = $0.toHex() ?? "#007AFF" }
                        ))
                        .labelsHidden()
                        .frame(width: 30)
                        Button("Add") {
                            addNewTag()
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }

                Section("Available Tags") {
                    ForEach(allTags.filter { !task.tags.contains($0) }) { tag in
                        Button(action: { addTag(tag) }) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: tag.color))
                                    .frame(width: 10, height: 10)
                                Text(tag.name)
                                Spacer()
                                Image(systemName: "plus.circle")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section {
                HStack {
                    if task.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("Incomplete", systemImage: "circle")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Delete Task") {
                        modelContext.delete(task)
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func removeTag(_ tag: Tag) {
        task.tags.removeAll { $0.id == tag.id }
    }

    private func addTag(_ tag: Tag) {
        if !task.tags.contains(tag) {
            task.tags.append(tag)
        }
    }

    private func addNewTag() {
        guard !newTagName.isEmpty else { return }
        let tag = Tag(name: newTagName, color: newTagColor)
        modelContext.insert(tag)
        task.tags.append(tag)
        newTagName = ""
        showingTagPicker = false
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

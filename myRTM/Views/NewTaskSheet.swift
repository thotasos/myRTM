import SwiftUI
import SwiftData

struct NewTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskList.name) private var lists: [TaskList]

    let selectedList: TaskList?
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate: Date?
    @State private var priority = 4
    @State private var selectedListId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Task")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            // Form
            Form {
                Section("Title") {
                    TextField("What needs to be done?", text: $title)
                        .textFieldStyle(.plain)
                        .font(.title3)
                }

                Section("List") {
                    Picker("List", selection: $selectedListId) {
                        ForEach(lists.filter { !$0.isSmartList }) { list in
                            HStack {
                                Circle()
                                    .fill(Color(hex: list.color))
                                    .frame(width: 8, height: 8)
                                Text(list.name)
                            }
                            .tag(list.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Due Date") {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.field)
                    .labelsHidden()

                    if dueDate != nil {
                        Button("Clear") {
                            dueDate = nil
                        }
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Highest").tag(1)
                        Text("High").tag(2)
                        Text("Low").tag(3)
                        Text("None").tag(4)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .formStyle(.grouped)

            Divider()

            // Footer
            HStack {
                Spacer()
                Button("Create Task") {
                    createTask()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
            }
            .padding()
        }
        .frame(width: 400, height: 450)
        .onAppear {
            selectedListId = selectedList?.id ?? lists.first?.id
        }
    }

    private func createTask() {
        let task = TaskItem(
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        )

        if let listId = selectedListId,
           let list = lists.first(where: { $0.id == listId }) {
            task.taskList = list
        }

        modelContext.insert(task)
        isPresented = false
    }
}

struct NewListSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var color = "#007AFF"

    let presetColors = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#007AFF", "#5856D6", "#AF52DE", "#FF2D55"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New List")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            // Form
            Form {
                Section("Name") {
                    TextField("List name", text: $name)
                        .textFieldStyle(.plain)
                }

                Section("Color") {
                    HStack(spacing: 8) {
                        ForEach(presetColors, id: \.self) { presetColor in
                            Circle()
                                .fill(Color(hex: presetColor))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(color == presetColor ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    color = presetColor
                                }
                        }
                    }

                    HStack {
                        Text("Custom:")
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: color) },
                            set: { color = $0.toHex() ?? "#007AFF" }
                        ))
                        .labelsHidden()
                    }
                }
            }
            .formStyle(.grouped)

            Divider()

            // Footer
            HStack {
                Spacer()
                Button("Create List") {
                    createList()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
            }
            .padding()
        }
        .frame(width: 350, height: 300)
    }

    private func createList() {
        let list = TaskList(name: name, color: color, isSmartList: false, isDefault: false, smartListType: nil)
        modelContext.insert(list)
        isPresented = false
    }
}

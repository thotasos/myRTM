import SwiftUI
import SwiftData
import UserNotifications

@main
struct myRTMApp: App {
    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            TaskList.self,
            Tag.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Create default smart lists if none exist
            let context = container.mainContext
            let descriptor = FetchDescriptor<TaskList>()
            let existingLists = try context.fetch(descriptor)

            if existingLists.isEmpty {
                let smartLists = [
                    TaskList(name: "Today", color: "#007AFF", isSmartList: true, isDefault: true, smartListType: .today),
                    TaskList(name: "Overdue", color: "#FF3B30", isSmartList: true, isDefault: true, smartListType: .overdue),
                    TaskList(name: "Completed", color: "#34C759", isSmartList: true, isDefault: true, smartListType: .completed),
                    TaskList(name: "All Tasks", color: "#8E8E93", isSmartList: true, isDefault: true, smartListType: .all)
                ]

                for list in smartLists {
                    context.insert(list)
                }

                // Create default "Inbox" list
                let inbox = TaskList(name: "Inbox", color: "#8E8E93", isSmartList: false, isDefault: true, smartListType: nil)
                context.insert(inbox)

                // Add sample data
                let workList = TaskList(name: "Work", color: "#007AFF", isSmartList: false, isDefault: false, smartListType: nil)
                let personalList = TaskList(name: "Personal", color: "#34C759", isSmartList: false, isDefault: false, smartListType: nil)
                context.insert(workList)
                context.insert(personalList)

                let urgentTag = Tag(name: "urgent", color: "#FF3B30")
                let homeTag = Tag(name: "home", color: "#34C759")
                context.insert(urgentTag)
                context.insert(homeTag)

                // Create sample tasks
                let calendar = Calendar.current
                let today = Date()
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

                let tasks = [
                    TaskItem(title: "Review quarterly report", notes: "Check all metrics", dueDate: today, priority: 1, taskList: workList, tags: [urgentTag]),
                    TaskItem(title: "Email client updates", notes: "Send project status", dueDate: tomorrow, priority: 2, taskList: workList, tags: []),
                    TaskItem(title: "Buy groceries", notes: "Milk, eggs, bread", dueDate: today, priority: 3, taskList: personalList, tags: [homeTag]),
                    TaskItem(title: "Schedule dentist appointment", notes: "Check insurance", dueDate: tomorrow, priority: 4, taskList: personalList, tags: [homeTag]),
                    TaskItem(title: "Finish presentation", notes: "Slides for Monday", dueDate: yesterday, priority: 1, taskList: workList, tags: [urgentTag])
                ]

                for task in tasks {
                    context.insert(task)
                }

                try context.save()
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.automatic)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .newItem) {
                Divider()

                Button("New Task") {
                    NotificationCenter.default.post(name: .newTask, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("New List") {
                    NotificationCenter.default.post(name: .newList, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])

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
        }
    }
}

extension Notification.Name {
    static let newTask = Notification.Name("newTask")
    static let newList = Notification.Name("newList")
    static let setPriority = Notification.Name("setPriority")
}

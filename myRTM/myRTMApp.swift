import SwiftUI
import SwiftData

@main
struct myRTMApp: App {
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
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.automatic)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Task") {
                    NotificationCenter.default.post(name: .newTask, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("New List") {
                    NotificationCenter.default.post(name: .newList, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
    }
}

extension Notification.Name {
    static let newTask = Notification.Name("newTask")
    static let newList = Notification.Name("newList")
}

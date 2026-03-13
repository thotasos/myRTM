import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskList.createdAt) private var lists: [TaskList]
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var selectedList: TaskList?
    @State private var selectedTask: TaskItem?
    @State private var showingNewTask = false
    @State private var showingNewList = false
    @State private var searchText = ""
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                lists: lists,
                selectedList: $selectedList,
                showingNewList: $showingNewList
            )
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } content: {
            TaskListView(
                selectedList: selectedList,
                selectedTask: $selectedTask,
                allTags: allTags,
                showingNewTask: $showingNewTask
            )
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 600)
        } detail: {
            if let task = selectedTask {
                TaskDetailView(task: task, allTags: allTags)
                    .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 350)
            } else {
                Text("Select a task")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            if selectedList == nil, let firstList = lists.first {
                selectedList = firstList
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newTask)) { _ in
            showingNewTask = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .newList)) { _ in
            showingNewList = true
        }
        .sheet(isPresented: $showingNewTask) {
            NewTaskSheet(selectedList: selectedList, isPresented: $showingNewTask)
        }
        .sheet(isPresented: $showingNewList) {
            NewListSheet(isPresented: $showingNewList)
        }
    }
}

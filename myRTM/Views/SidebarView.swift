import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext

    let lists: [TaskList]
    @Binding var selectedList: TaskList?
    @Binding var showingNewList: Bool

    var smartLists: [TaskList] {
        lists.filter { $0.isSmartList }
    }

    var userLists: [TaskList] {
        lists.filter { !$0.isSmartList }
    }

    var body: some View {
        List(selection: $selectedList) {
            Section("Smart Lists") {
                ForEach(smartLists) { list in
                    NavigationLink(value: list) {
                        SmartListRow(list: list)
                    }
                }
            }

            Section("My Lists") {
                ForEach(userLists) { list in
                    NavigationLink(value: list) {
                        ListRow(list: list)
                    }
                }
                .onDelete(perform: deleteUserLists)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("myRTM")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showingNewList = true }) {
                    Image(systemName: "plus")
                }
                .help("New List")
            }
        }
    }

    private func deleteUserLists(at offsets: IndexSet) {
        for index in offsets {
            let list = userLists[index]
            if selectedList?.id == list.id {
                selectedList = lists.first
            }
            modelContext.delete(list)
        }
    }
}

struct SmartListRow: View {
    let list: TaskList

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: list.color))
                .frame(width: 10, height: 10)
            Text(list.name)
            Spacer()
        }
    }
}

struct ListRow: View {
    @Bindable var list: TaskList

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: list.color))
                .frame(width: 10, height: 10)
            Text(list.name)
            Spacer()
            Text("\(list.tasks.filter { !$0.isCompleted }.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

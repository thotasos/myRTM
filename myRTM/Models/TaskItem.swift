import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var notes: String
    var dueDate: Date?
    var priority: Int // 1=Highest, 2=High, 3=Low, 4=None
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    @Relationship(inverse: \TaskList.tasks)
    var taskList: TaskList?

    @Relationship(inverse: \Tag.tasks)
    var tags: [Tag]

    init(
        id: UUID = UUID(),
        title: String = "",
        notes: String = "",
        dueDate: Date? = nil,
        priority: Int = 4,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        taskList: TaskList? = nil,
        tags: [Tag] = []
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.taskList = taskList
        self.tags = tags
    }
}

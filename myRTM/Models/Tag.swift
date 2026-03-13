import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID
    var name: String
    var color: String
    var createdAt: Date

    @Relationship
    var tasks: [TaskItem]

    init(
        id: UUID = UUID(),
        name: String = "",
        color: String = "#007AFF",
        createdAt: Date = Date(),
        tasks: [TaskItem] = []
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
        self.tasks = tasks
    }
}

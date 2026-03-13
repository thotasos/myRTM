import Foundation
import SwiftData

enum SmartListType: String, Codable {
    case today = "today"
    case overdue = "overdue"
    case completed = "completed"
    case all = "all"
}

@Model
final class TaskList {
    var id: UUID
    var name: String
    var color: String
    var isSmartList: Bool
    var isDefault: Bool
    var smartListType: SmartListType?
    var createdAt: Date

    @Relationship
    var tasks: [TaskItem]

    init(
        id: UUID = UUID(),
        name: String = "",
        color: String = "#8E8E93",
        isSmartList: Bool = false,
        isDefault: Bool = false,
        smartListType: SmartListType? = nil,
        createdAt: Date = Date(),
        tasks: [TaskItem] = []
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.isSmartList = isSmartList
        self.isDefault = isDefault
        self.smartListType = smartListType
        self.createdAt = createdAt
        self.tasks = tasks
    }
}

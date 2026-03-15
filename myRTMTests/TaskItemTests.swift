import XCTest
@testable import myRTM

final class TaskItemTests: XCTestCase {

    func testTaskItemCreation() {
        // Given
        let title = "Test Task"
        let notes = "Test Notes"
        let priority = 1

        // When
        let task = TaskItem(
            title: title,
            notes: notes,
            priority: priority
        )

        // Then
        XCTAssertEqual(task.title, title)
        XCTAssertEqual(task.notes, notes)
        XCTAssertEqual(task.priority, priority)
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.dueDate)
        XCTAssertNil(task.completedAt)
    }

    func testTaskItemDefaultPriority() {
        // When
        let task = TaskItem(title: "Test")

        // Then
        XCTAssertEqual(task.priority, 4) // Default is None
    }

    func testTaskItemToggleComplete() {
        // Given
        let task = TaskItem(title: "Test", isCompleted: false)

        // When
        task.isCompleted = true
        task.completedAt = task.isCompleted ? Date() : nil

        // Then
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }

    func testTaskItemPriorityValues() {
        // Test all priority levels
        for priority in 1...4 {
            let task = TaskItem(title: "Test", priority: priority)
            XCTAssertEqual(task.priority, priority)
        }
    }
}

import XCTest
@testable import myRTM

final class TagTests: XCTestCase {

    func testTagCreation() {
        // Given
        let name = "urgent"
        let color = "#FF3B30"

        // When
        let tag = Tag(name: name, color: color)

        // Then
        XCTAssertEqual(tag.name, name)
        XCTAssertEqual(tag.color, color)
    }

    func testTagDefaultValues() {
        // When
        let tag = Tag()

        // Then
        XCTAssertEqual(tag.color, "#007AFF") // Default blue
    }

    func testTagWithMultipleTasks() {
        // Given
        let tag = Tag(name: "work", color: "#007AFF")
        let task1 = TaskItem(title: "Task 1")
        let task2 = TaskItem(title: "Task 2")

        // When
        tag.tasks = [task1, task2]

        // Then
        XCTAssertEqual(tag.tasks.count, 2)
    }
}

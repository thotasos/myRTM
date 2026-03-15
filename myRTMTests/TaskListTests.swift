import XCTest
@testable import myRTM

final class TaskListTests: XCTestCase {

    func testTaskListCreation() {
        // Given
        let name = "Work"
        let color = "#007AFF"

        // When
        let list = TaskList(name: name, color: color)

        // Then
        XCTAssertEqual(list.name, name)
        XCTAssertEqual(list.color, color)
        XCTAssertFalse(list.isSmartList)
        XCTAssertFalse(list.isDefault)
    }

    func testTaskListDefaultValues() {
        // When
        let list = TaskList()

        // Then
        XCTAssertEqual(list.color, "#8E8E93") // Default gray
        XCTAssertFalse(list.isSmartList)
        XCTAssertFalse(list.isDefault)
        XCTAssertNil(list.smartListType)
    }

    func testSmartListCreation() {
        // When
        let todayList = TaskList(
            name: "Today",
            color: "#007AFF",
            isSmartList: true,
            isDefault: true,
            smartListType: .today
        )

        // Then
        XCTAssertTrue(todayList.isSmartList)
        XCTAssertTrue(todayList.isDefault)
        XCTAssertEqual(todayList.smartListType, .today)
    }

    func testAllSmartListTypes() {
        // Test all smart list types
        let types: [SmartListType] = [.today, .overdue, .completed, .all]

        for type in types {
            let list = TaskList(
                name: type.rawValue.capitalized,
                isSmartList: true,
                smartListType: type
            )
            XCTAssertEqual(list.smartListType, type)
        }
    }
}

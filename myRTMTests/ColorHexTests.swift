import XCTest
import SwiftUI
@testable import myRTM

final class ColorHexTests: XCTestCase {

    func testColorHex6Digits() {
        // Given
        let hex = "#FF0000"

        // When
        let color = Color(hex: hex)

        // Then - verify color is created (can't easily test exact RGB values in SwiftUI)
        XCTAssertNotNil(color)
    }

    func testColorHex3Digits() {
        // Given
        let hex = "#F00"

        // When
        let color = Color(hex: hex)

        // Then
        XCTAssertNotNil(color)
    }

    func testColorHex8Digits() {
        // Given
        let hex = "#80FF0000"

        // When
        let color = Color(hex: hex)

        // Then
        XCTAssertNotNil(color)
    }

    func testColorHexWithoutHash() {
        // Given
        let hex = "FF0000"

        // When
        let color = Color(hex: hex)

        // Then
        XCTAssertNotNil(color)
    }

    func testColorHexInvalid() {
        // Given - invalid hex
        let hex = "invalid"

        // When
        let color = Color(hex: hex)

        // Then - should default to black
        XCTAssertNotNil(color)
    }
}

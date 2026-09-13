import XCTest
import SwiftUI
@testable import BlueJay

final class FlowLayoutTests: XCTestCase {
    func testInitialization() {
        let layout = FlowLayout(spacing: 10)
        XCTAssertEqual(layout.spacing, 10)
    }

    func testDefaultSpacing() {
        let layout = FlowLayout()
        XCTAssertEqual(layout.spacing, 6)
    }
}

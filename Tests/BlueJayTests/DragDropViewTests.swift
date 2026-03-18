import XCTest
import SwiftUI
@testable import BlueJay

final class DragDropViewTests: XCTestCase {
  func testInitialization() {
    let view = DragDropView(onDrop: { _ in }) {
      Text("Hello")
    }
    XCTAssertNotNil(view)
  }
  
  @MainActor
  func testViewExtension() {
    let view = Text("Hello").fileDragAndDrop(onDrop: { _ in })
    XCTAssertNotNil(view)
  }
}

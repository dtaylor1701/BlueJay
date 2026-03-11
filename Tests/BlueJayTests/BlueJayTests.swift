import SwiftUI
import Testing

@testable import BlueJay

@Suite("BlueJay Tests")
struct BlueJayTests {

  @Test("ProgressState logic")
  func testProgressState() {
    let started = ProgressState<String, Error>.started
    if case .started = started {
      // Success
    } else {
      Issue.record("Expected .started")
    }

    let success = ProgressState<String, Error>.finished(.success("Done"))
    if case .finished(let result) = success {
      switch result {
      case .success(let value):
        #expect(value == "Done")
      case .failure:
        Issue.record("Expected success")
      }
    } else {
      Issue.record("Expected .finished")
    }
  }

  struct TestItem: Identifiable {
    let id: Int
    var name: String
  }

  @Test("Identifiable binding extension")
  @MainActor
  func testIdentifiableBinding() {
    var items = [
      TestItem(id: 1, name: "One"),
      TestItem(id: 2, name: "Two"),
    ]

    let arrayBinding = Binding(
      get: { items },
      set: { items = $0 }
    )

    let item1 = items[0]
    guard let item1Binding = item1.binding(in: arrayBinding) else {
      Issue.record("Should have found binding for item 1")
      return
    }

    #expect(item1Binding.wrappedValue.name == "One")

    item1Binding.wrappedValue.name = "Updated One"
    #expect(items[0].name == "Updated One")

    let nonExistentItem = TestItem(id: 3, name: "Three")
    #expect(nonExistentItem.binding(in: arrayBinding) == nil)
  }
}

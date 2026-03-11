import SwiftUI
import Testing

@testable import BlueJay

@Suite("Binding Extensions Tests")
struct BindingExtensionsTests {

  @Test("Optional binding extension")
  @MainActor
  func testOptionalBinding() {
    var optionalString: String? = "Hello"
    
    let binding = Binding(
      get: { optionalString },
      set: { optionalString = $0 }
    )
    
    guard let optionalBinding = binding.optionalBinding() else {
      Issue.record("Should have found optional binding for 'Hello'")
      return
    }
    
    #expect(optionalBinding.wrappedValue == "Hello")
    
    optionalBinding.wrappedValue = "World"
    #expect(optionalString == "World")
    
    optionalString = nil
    #expect(binding.optionalBinding() == nil)
  }
}

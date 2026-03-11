import SwiftUI

public extension Binding {
  func optionalBinding<T>() -> Binding<T>? where Value == Optional<T> {
    guard let value = wrappedValue else { return nil }
    
    return Binding<T> {
      return value
    } set: { newValue in
      wrappedValue = newValue
    }
  }
}

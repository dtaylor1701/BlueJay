import SwiftUI

public struct ScrollIfNeeded: ViewModifier {
  public init() {}
  
  public func body(content: Content) -> some View {
    ViewThatFits {
      content
      ScrollView {
        content
      }
    }
  }
}

public extension View {
  func scrollIfNeeded() -> some View {
    modifier(ScrollIfNeeded())
  }
}

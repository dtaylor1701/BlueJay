import SwiftUI

/// A view modifier that applies a standard title style with padding.
public struct TitleStyle: ViewModifier {
  public init() {}
  
  public func body(content: Content) -> some View {
    content
      .padding(16)
      .font(.title)
  }
}

public extension View {
  /// Applies a standard title style to the view.
  func titleStyle() -> some View {
    modifier(TitleStyle())
  }
}

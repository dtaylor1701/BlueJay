//
//  ListButtonContentContainer.swift
//
//  Created by David Taylor on 2/17/24.
//
import SwiftUI

/// A view modifier that applies standard styling for list items intended to be used as buttons.
///
/// This provides consistent padding, shape, and background highlighting for list elements.
public struct ListButtonContentContainer: ViewModifier {
  /// Whether the item is currently selected.
  public let isSelected: Bool

  /// - Parameter isSelected: Whether the list item should be highlighted as selected.
  public init(isSelected: Bool) {
    self.isSelected = isSelected
  }

  public func body(content: Content) -> some View {
    HStack {
      content
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .contentShape(Rectangle())
    .background(isSelected ? Color.accentColor : Color.clear)
    .clipShape(RoundedRectangle(cornerRadius: 4.0))
  }
}

extension View {
  /// Styles the view as a standard button within a list.
  ///
  /// This applies standard padding, background, and highlighting.
  ///
  /// - Parameter isSelected: Whether the view should be styled as selected.
  public func asListButtonContent(isSelected: Bool? = nil) -> some View {
    modifier(ListButtonContentContainer(isSelected: isSelected ?? false))
  }
}

#Preview {
  List {
    Button {
      
    } label: {
      Text("Some Button")
    }
    .buttonStyle(.plain)
    .modifier(ListButtonContentContainer(isSelected: false))
    Button {
      
    } label: {
      Text("Some Selected Button")
    }
    .buttonStyle(.plain)
    .modifier(ListButtonContentContainer(isSelected: true))
  }
}

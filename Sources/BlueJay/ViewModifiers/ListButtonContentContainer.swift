//
//  ListButtonContentContainer.swift
//
//  Created by David Taylor on 2/17/24.
//
import SwiftUI

public struct ListButtonContentContainer: ViewModifier {
  let isSelected: Bool

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
  public func asListButtonContent(isSelected: Bool? = nil) -> some View {
    modifier(ListButtonContentContainer(isSelected: isSelected ?? false))
  }
}

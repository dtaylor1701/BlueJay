//
//  Identifiable+Extensions.swift
//
//  Created by David Taylor on 2/17/24.
//
import SwiftUI

public extension Identifiable {
  /// Creates a `Binding` for an element within a `Binding` of an array.
  ///
  /// This is particularly useful when you have a list of items and want to pass
  /// a binding to a specific item to a detail view or editor.
  ///
  /// - Parameter arrayBinding: A binding to an array containing elements of this type.
  /// - Returns: A binding to the element if it exists in the array; otherwise, `nil`.
  func binding(in arrayBinding: Binding<[Self]>) -> Binding<Self>? {
    guard let index = arrayBinding.wrappedValue.firstIndex(where: { $0.id == id }) else { return nil }

    return Binding {
      arrayBinding.wrappedValue[index]
    } set: { newValue in
      arrayBinding.wrappedValue[index] = newValue
    }
  }
}

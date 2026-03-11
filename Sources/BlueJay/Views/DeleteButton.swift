//
//  DeleteButton.swift
//
//  Created by David Taylor on 2/17/24.
//

import Foundation
import Goose
import SwiftUI

/// A button that deletes an item from a binding to an array.
///
/// This view provides a standard "trash" icon button with a "destructive" role.
public struct DeleteButton<Item: Identifiable>: View {
  /// The item to be deleted.
  public let item: Item

  /// A binding to the array from which the item should be removed.
  @Binding
  public var array: [Item]

  /// - Parameters:
  ///   - item: The item to delete.
  ///   - array: A binding to the array containing the item.
  public init(item: Item, array: Binding<[Item]>) {
    self.item = item
    self._array = array
  }

  public var body: some View {
    Button(role: .destructive) {
      array.delete(item)
    } label: {
      Label {
        Text("Delete")
      } icon: {
        Image(systemName: "trash")
      }
      .padding(4)
    }
  }
}

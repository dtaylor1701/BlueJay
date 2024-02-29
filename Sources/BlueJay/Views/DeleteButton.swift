//
//  DeleteButton.swift
//
//  Created by David Taylor on 2/17/24.
//

import Foundation
import Goose
import SwiftUI

public struct DeleteButton<Item: Identifiable>: View {
  public let item: Item

  @Binding
  public var array: [Item]

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

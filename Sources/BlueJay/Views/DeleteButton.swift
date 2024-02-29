//
//  DeleteButton.swift
//
//  Created by David Taylor on 2/17/24.
//

import Foundation
import SwiftUI

public struct DeleteButton<Item: Identifiable>: View {
  let item: Item
  
  @Binding
  var array: Array<Item>
  
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

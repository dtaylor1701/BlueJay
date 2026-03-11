//
//  InstructionsView.swift
//
//  Created by David Taylor on 6/2/24.
//

import SwiftUI

public struct InstructionsView: View {
  public let title: String
  public let items: [String]
  
  public init(title: String, items: [String]) {
    self.title = title
    self.items = items
  }
  
  public var body: some View {
    List {
      Text(title)
        .font(.headline)
        .listRowSeparator(.hidden)
        .padding(.bottom, 20)
      ForEach(items, id: \.self) { item in
        InstructionBullet(item)
          .listRowSeparator(.hidden)
      }
    }
    .frame(minWidth: 400)
  }
}

public struct InstructionBullet: View {
  let text: String
  
  public init(_ text: String) {
    self.text = text
  }
  
  public var body: some View {
    HStack {
      Circle()
        .frame(width: 4, height: 4)
      Text(text)
    }
  }
}

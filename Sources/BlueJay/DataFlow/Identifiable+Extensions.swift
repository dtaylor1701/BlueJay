//
//  Identifiable+Extensions.swift
//
//  Created by David Taylor on 2/17/24.
//
import SwiftUI

extension Identifiable {
  func binding(in arrayBinding: Binding<Array<Self>>) -> Binding<Self>? {
    guard let index = arrayBinding.wrappedValue.index(of: self) else { return nil }
    
    return Binding {
      arrayBinding.wrappedValue[index]
    } set: { newValue in
      arrayBinding.wrappedValue[index] = newValue
    }
  }
}

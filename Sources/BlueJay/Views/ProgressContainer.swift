//
//  File.swift
//  
//
//  Created by David Taylor on 5/22/24.
//

import Foundation
import SwiftUI

public struct ProgressContainer<Content: View, Value, Error: Swift.Error>: View {
  private let progressState: ProgressState<Value, Error>
  private let content: (Value) -> Content
  
  public init(progressState: ProgressState<Value, Error>, content: @escaping (Value) -> Content) {
    self.progressState = progressState
    self.content = content
  }
  
  public var body: some View {
    switch progressState {
    case .started:
      ProgressView()
    case .finished(let result):
      switch result {
      case .success(let value):
        content(value)
      case .failure(let error):
        Text("Something went wrong.")
      }
    }
  }
}

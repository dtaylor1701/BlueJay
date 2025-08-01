//
//  File.swift
//
//
//  Created by David Taylor on 5/22/24.
//

import Foundation
import SwiftUI

public struct ProgressContainer<Content: View, ErrorContent: View, Value, Error: Swift.Error>: View
{
  private let progressState: ProgressState<Value, Error>
  private let content: (Value) -> Content
  private let errorContent: (Error) -> ErrorContent

  public init(
    progressState: ProgressState<Value, Error>, content: @escaping (Value) -> Content,
    errorContent: @escaping (Error) -> ErrorContent
  ) {
    self.progressState = progressState
    self.content = content
    self.errorContent = errorContent
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
        errorContent(error)
      }
    }
  }
}

#Preview {
  ProgressContainer(progressState: ProgressState<Int, Error>.started) { value in
    Text("\(value)")
  } errorContent: { error in
    Text("\(error.localizedDescription)")
  }
  .padding()
}

#Preview {
  ProgressContainer(progressState: ProgressState<Int, Error>.finished(.success(3))) { value in
    Text("\(value)")
  } errorContent: { error in
    Text("\(error.localizedDescription)")
  }
  .padding()
}

#Preview {
  ProgressContainer(
    progressState: ProgressState<Int, Error>.finished(.failure(NSError(domain: "test", code: 500)))
  ) { value in
    Text("\(value)")
  } errorContent: { error in
    Text("\(error.localizedDescription)")
  }
  .padding()
}

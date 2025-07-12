//
//  SheetContainer.swift
//
//  Created by David Taylor on 2/17/24.
//

import Foundation
import SwiftUI

public struct SheetContainer: ViewModifier {
  public enum Configuration {
    case done
    case cancel
    case cancelDone(onDone: () -> Void)
  }
  
  @Environment(\.dismiss)
  private var dismiss
  
  private let configuration: Configuration
  
  private var showCancel: Bool {
    switch configuration {
    case .done:
      false
    case .cancel, .cancelDone:
      true
    }
  }
  
  private var showDone: Bool {
    switch configuration {
    case .cancel:
      false
    case .done, .cancelDone:
      true
    }
  }
  
  public init(configuration: Configuration = .done) {
    self.configuration = configuration
  }
  
  public func body(content: Content) -> some View {
    VStack {
      content
      navigationElements
    }
  }
  
  @ViewBuilder
  private var navigationElements: some View {
    VStack(spacing: .zero) {
      Divider()
      HStack {
        Spacer()
        if showCancel {
          cancelButton
        }
        if showDone {
          doneButton
            .buttonStyle(.borderedProminent)
        }
      }
      .padding()
    }
  }
  
  @ViewBuilder
  private var doneButton: some View {
    Button {
      dismiss()
      if case let Configuration.cancelDone(onDone) = configuration {
        onDone()
      }
    } label: {
      Text("Done")
    }
  }
  
  @ViewBuilder
  private var cancelButton: some View {
    Button(role:.cancel) {
      dismiss()
    } label: {
      Text("Cancel")
    }
  }
}

public extension View {
  func asSheet(configuration: SheetContainer.Configuration) -> some View {
    modifier(SheetContainer(configuration: configuration))
  }
}

#Preview {
  Text("Hello there!")
    .asSheet(configuration: .cancel)
}

#Preview {
  Text("Hello there!")
    .asSheet(configuration: .done)
}

#Preview {
  Text("Hello there!")
    .asSheet(configuration: .cancelDone(onDone: {
      
    }))
}

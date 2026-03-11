//
//  SheetContainer.swift
//
//  Created by David Taylor on 2/17/24.
//

import Foundation
import SwiftUI

/// A view modifier that adds a standard footer for sheets with "Done" and "Cancel" buttons.
///
/// Use this to quickly add common navigation elements to views presented in a sheet.
public struct SheetContainer: ViewModifier {
  /// The configuration options for the sheet container's buttons.
  public enum Configuration {
    /// Only the "Done" button is shown.
    case done
    /// Only the "Cancel" button is shown.
    case cancel
    /// Both "Cancel" and "Done" buttons are shown, with an optional action for "Done".
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
  /// Wraps the view in a `SheetContainer` with the specified configuration.
  ///
  /// This is typically used for views presented as a sheet to provide a consistent footer.
  ///
  /// - Parameter configuration: The button configuration to use in the footer.
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

import SwiftUI

/// A view modifier that presents an alert when an error is present.
public struct ErrorAlertModifier: ViewModifier {
  @Binding var error: (any Error)?
  let title: String
  let buttonText: String

  public func body(content: Content) -> some View {
    content
      .alert(
        title,
        isPresented: Binding(
          get: { error != nil },
          set: { if !$0 { error = nil } }
        ),
        presenting: error
      ) { _ in
        Button(buttonText) {
          error = nil
        }
      } message: { error in
        Text(error.localizedDescription)
      }
  }
}

public extension View {
  /// Presents an alert when the provided error binding is non-nil.
  ///
  /// - Parameters:
  ///   - error: A binding to an optional `Error` that triggers the alert.
  ///   - title: The title of the alert. Defaults to "Error".
  ///   - buttonText: The text for the dismissal button. Defaults to "OK".
  func errorAlert(
    error: Binding<(any Error)?>,
    title: String = "Error",
    buttonText: String = "OK"
  ) -> some View {
    self.modifier(ErrorAlertModifier(error: error, title: title, buttonText: buttonText))
  }

  /// Presents an alert when the provided progress state is in a failure state.
  ///
  /// - Parameters:
  ///   - state: A binding to a `ProgressState`.
  ///   - title: The title of the alert. Defaults to "Error".
  ///   - buttonText: The text for the dismissal button. Defaults to "OK".
  func errorAlert<Value, Error: Swift.Error>(
    for state: Binding<ProgressState<Value, Error>>,
    title: String = "Error",
    buttonText: String = "OK"
  ) -> some View {
    let errorBinding = Binding<(any Swift.Error)?>(
      get: {
        if case .finished(let result) = state.wrappedValue,
           case .failure(let error) = result {
          return error
        }
        return nil
      },
      set: { newValue in
        if newValue == nil,
           case .finished(let result) = state.wrappedValue,
           case .failure = result {
          state.wrappedValue = .idle
        }
      }
    )
    return self.errorAlert(error: errorBinding, title: title, buttonText: buttonText)
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State var error: (any Error)?
    
    var body: some View {
      VStack {
        Button("Trigger Error") {
          error = NSError(domain: "BlueJay", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong!"])
        }
      }
      .errorAlert(error: $error)
    }
  }
  
  return PreviewWrapper()
}

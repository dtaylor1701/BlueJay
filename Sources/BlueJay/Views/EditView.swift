import SwiftUI

/// A wrapper view that provides a standard navigation-based editing interface.
///
/// It includes a navigation view with "Done" and "Cancel" buttons in the toolbar.
public struct EditView<Content: View>: View {
  private let content: () -> Content
  private let onCancel: () -> Void
  private let onDone: () -> Void

  @Environment(\.dismiss)
  private var dismiss

  /// - Parameters:
  ///   - content: The content of the editor.
  ///   - onDone: Closure called when the "Done" button is pressed.
  ///   - onCancel: Closure called when the "Cancel" button is pressed.
  public init(
    @ViewBuilder content: @escaping () -> Content,
    onDone: @escaping () -> Void,
    onCancel: @escaping () -> Void = {}
  ) {
    self.content = content
    self.onDone = onDone
    self.onCancel = onCancel
  }

  public var body: some View {
    NavigationView {
      content()
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button("Done") {
              dismiss()
              onDone()
            }
          }

          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              dismiss()
              onCancel()
            }
          }
        }
    }
  }
}

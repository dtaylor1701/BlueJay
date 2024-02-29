import SwiftUI

public struct EditView<Content: View>: View {
  private let content: () -> Content
  private let onCancel: () -> Void
  private let onDone: () -> Void

  @Environment(\.dismiss)
  private var dismiss

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

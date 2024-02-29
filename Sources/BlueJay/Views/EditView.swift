import SwiftUI

public struct EditView<Content: View>: View {
  let content: () -> Content
  let onCancel: () -> Void
  let onDone: () -> Void

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
      content
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

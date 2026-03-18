import SwiftUI
import UniformTypeIdentifiers

/// A view that handles file drag-and-drop operations.
///
/// `DragDropView` provides a standardized way to accept file drops across platforms.
/// It wraps a content view and triggers a callback when files are dropped onto it.
public struct DragDropView<Content: View>: View {
  @Binding private var isTargeted: Bool
  private let onDrop: ([URL]) -> Void
  private let content: () -> Content

  /// Creates a new `DragDropView`.
  ///
  /// - Parameters:
  ///   - isTargeted: A binding that tracks whether a drag operation is currently over the view.
  ///   - onDrop: A closure called with the URLs of the dropped files.
  ///   - content: The content to display within the drag-and-drop area.
  public init(
    isTargeted: Binding<Bool> = .constant(false),
    onDrop: @escaping ([URL]) -> Void,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self._isTargeted = isTargeted
    self.onDrop = onDrop
    self.content = content
  }

  public var body: some View {
    content()
      .onDrop(of: [.fileURL, .item, .text], delegate: FileDropDelegate(isTargeted: $isTargeted, onDrop: onDrop))
  }
}

struct FileDropDelegate: DropDelegate {
  @Binding var isTargeted: Bool
  let onDrop: ([URL]) -> Void

  func performDrop(info: DropInfo) -> Bool {
    let providers = info.itemProviders(for: [.fileURL, .item, .text])
    let group = DispatchGroup()
    var droppedURLs: [URL] = []

    BlueJayLog.view.debug("FileDropDelegate: Received drop with \(providers.count) providers")

    for provider in providers {
      group.enter()
      // Use the raw identifier for maximum compatibility
      provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
        defer { group.leave() }
        
        if let data = item as? Data {
          if let url = URL(dataRepresentation: data, relativeTo: nil) {
            droppedURLs.append(url)
            BlueJayLog.view.debug("FileDropDelegate: Dropped URL (from data): \(url)")
          }
        } else if let url = item as? URL {
          droppedURLs.append(url)
          BlueJayLog.view.debug("FileDropDelegate: Dropped URL (from URL): \(url)")
        } else if let error = error {
          BlueJayLog.view.error("FileDropDelegate: Error loading item: \(error.localizedDescription)")
        }
      }
    }

    group.notify(queue: .main) {
      BlueJayLog.view.debug("FileDropDelegate: Finished processing drop. Total URLs: \(droppedURLs.count)")
      if !droppedURLs.isEmpty {
        onDrop(droppedURLs)
      }
    }

    return true
  }

  func dropEntered(info: DropInfo) {
    isTargeted = true
  }

  func dropExited(info: DropInfo) {
    isTargeted = false
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    return DropProposal(operation: .copy)
  }
}

extension View {
  /// Enables the view to accept dropped files.
  ///
  /// - Parameters:
  ///   - isTargeted: A binding that tracks whether a drag operation is currently over the view.
  ///   - onDrop: A closure called with the URLs of the dropped files.
  public func fileDragAndDrop(
    isTargeted: Binding<Bool> = .constant(false),
    onDrop: @escaping ([URL]) -> Void
  ) -> some View {
    modifier(FileDragAndDropModifier(isTargeted: isTargeted, onDrop: onDrop))
  }
}

private struct FileDragAndDropModifier: ViewModifier {
  @Binding var isTargeted: Bool
  let onDrop: ([URL]) -> Void

  func body(content: Content) -> some View {
    DragDropView(isTargeted: $isTargeted, onDrop: onDrop) {
      content
    }
  }
}

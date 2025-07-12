#if os(macOS)
import Foundation
import Goose
import SwiftUI

public struct FileDropArea: ViewModifier {
  @State private var isTargeted: Bool = false

  public let onDrop: (File) -> Void

  public init(onDrop: @escaping (File) -> Void) {
    self.onDrop = onDrop
  }

  public func body(content: Content) -> some View {
    content
      .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) }) {
          _ = provider.loadObject(ofClass: URL.self) { url, error in
            guard let url = url, let file = try? File.fromDroppedURL(url) else { return }

            onDrop(file)
          }
          return true
        }
        return false
      }
  }
}

extension View {
  public func fileDropArea(onDrop: @escaping (File) -> Void) -> some View {
    modifier(FileDropArea(onDrop: onDrop))
  }
}

extension File {
  static func fromDroppedURL(_ url: URL) throws -> File {
    let bookmark = try url.bookmarkData(options: .withSecurityScope)
    var stale: Bool = false
    let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &stale)
    return try File(at: url)
  }
}
#endif

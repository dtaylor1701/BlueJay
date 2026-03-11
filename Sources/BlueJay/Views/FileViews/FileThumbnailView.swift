#if os(macOS)
import Goose
import QuickLookThumbnailing
import SwiftUI

/// A view that generates and displays a thumbnail for a `File`.
///
/// It uses `QuickLookThumbnailing` to provide high-quality previews of
/// various file types on macOS.
public struct FileThumbnailView: View {
  @Environment(\.displayScale)
  private var scale

  @State var thumbnail: Image?
  @State var errored: Bool = false

  /// A binding to the `File` to generate a thumbnail for.
  @Binding var file: File

  /// - Parameter file: A binding to the `File`.
  public init(file: Binding<File>) {
    _file = file
  }

  /// - Parameter file: A static `File` instance.
  public init(file: File) {
    _file = .constant(file)
  }

  var content: some View {
    if errored {
      Image(systemName: "folder.badge.questionmark")
        .resizable()
    } else if let thumbnail {
      thumbnail
        .resizable()
    } else {
      Image(systemName: "document")
        .resizable()
    }
  }

  public var body: some View {
    GeometryReader { proxy in
      content
        .task {
          do {
            try await generateThumbnailRepresentations(size: proxy.size)
          } catch {
            errored = true
          }
        }
    }
  }

  /// Generates the thumbnail representation using `QLThumbnailGenerator`.
  func generateThumbnailRepresentations(size: CGSize) async throws {
    let url = try file.url()
    let request = QLThumbnailGenerator.Request(
      fileAt: url,
      size: size,
      scale: scale,
      representationTypes: .all)

    let generator = QLThumbnailGenerator.shared
    let representation = try await generator.generateBestRepresentation(for: request)
    thumbnail = Image(nsImage: representation.nsImage)
  }
}
#endif

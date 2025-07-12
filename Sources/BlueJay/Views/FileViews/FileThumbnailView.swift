#if os(macOS)
import Goose
import QuickLookThumbnailing
import SwiftUI

public struct FileThumbnailView: View {
  @Environment(\.displayScale)
  private var scale

  @State var thumbnail: Image?
  @State var errored: Bool = false

  @Binding var file: File

  public init(file: Binding<File>) {
    _file = file
  }

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

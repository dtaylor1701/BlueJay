#if os(macOS)
  import Goose
  import SwiftUI

  /// A view that loads and displays the binary data of a `File`.
  ///
  /// `FileDataView` handles reading the file's data asynchronously and provides
  /// it to a content builder.
  public struct FileDataView<Content: View>: View {

    /// A binding to the `File` whose data should be displayed.
    @Binding public var file: File
    @State var data: Data?

    /// A view builder that receives the file's data.
    public var content: (Data) -> Content

    /// - Parameters:
    ///   - file: A binding to the `File`.
    ///   - content: A view builder that receives the loaded `Data`.
    public init(file: Binding<File>, @ViewBuilder content: @escaping (Data) -> Content) {
      self._file = file
      self.content = content
    }

    public var body: some View {
      Group {
        if let data {
          content(data)
        } else {
          VStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("File could not be opened.")
          }
        }
      }
      .onChange(of: file.bookmark) { _ in
        data = try? file.data()
      }
      .task {
        data = try? file.data()
      }
    }
  }
#endif

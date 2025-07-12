#if os(macOS)
  import Goose
  import SwiftUI

  public struct FileDataView<Content: View>: View {

    @Binding public var file: File
    @State var data: Data?

    public var content: (Data) -> Content

    public init(file: Binding<File>, content: @escaping (Data) -> Content) {
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

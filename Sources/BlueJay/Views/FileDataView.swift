import Goose
import SwiftUI

public struct FileDataView<Content: View>: View {

  @Binding public var file: File
  public var content: (Data) -> Content

  public init(file: Binding<File>, content: @escaping (Data) -> Content) {
    self._file = file
    self.content = content
  }

  private var data: Data? {
    try? file.data()
  }

  public var body: some View {
    if let data {
      content(data)
    } else {
      VStack {
        Image(systemName: "exclamationmark.triangle.fill")
        Text("File could not be opened.")
      }
    }
  }
}

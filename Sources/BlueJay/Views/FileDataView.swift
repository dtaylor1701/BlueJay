import SwiftUI
import Goose

public struct FileDataView<Content: View>: View {
  public let file: File
  public var content: (Data) -> Content
  
  public init(file: File, content: @escaping (Data) -> Content) {
    self.file = file
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

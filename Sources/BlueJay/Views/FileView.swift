import UniformTypeIdentifiers
import SwiftUI
import Foundation
import Goose

public struct FileView: View {
  private let title: String
  private let allowedContentTypes: [UTType]
  
  @Binding
  private var file: File?
  
  @State
  private var isImporterPresented: Bool = false
  
  public init(title: String, file: Binding<File?>, allowedContentTypes: [UTType]) {
    _file = file
    self.title = title
    self.allowedContentTypes = allowedContentTypes
  }
  
  @ViewBuilder
  private var content: some View {
    if let file {
      if let url = try? file.url() {
        Button {
          NSWorkspace.shared.activateFileViewerSelecting([url])
        } label: {
          Label(url.lastPathComponent, systemImage: "doc.fill.badge.ellipsis")
        }
        .buttonStyle(.link)
      } else {
        Image(systemName: "exclamationmark.triangle.fill")
      }
    } else {
      EmptyView()
    }
  }
  
  public var body: some View {
    VStack {
      content
      Button {
        isImporterPresented = true
      } label: {
        Label("Select \(title)", systemImage: "doc.text.magnifyingglass")
      }
    }
    .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: allowedContentTypes) { result in
      switch result {
      case .success(let url):
        do {
          file = try File(at: url)
        } catch {
          log.error("\(error)")
        }
        
      case .failure(let error):
        log.error("\(error)")
      }
    }
  }
}

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
  
  public var body: some View {
    HStack {
      if let file {
        if let url = try? file.url() {
          Button {
            NSWorkspace.shared.activateFileViewerSelecting([url])
          } label: {
            Text(url.lastPathComponent)
          }
          .buttonStyle(.link)
        } else {
          Image(systemName: "exclamationmark.triangle.fill")
        }
        Menu {
          selectFileButton
            .labelStyle(.titleAndIcon)
          clearFileButton
            .labelStyle(.titleAndIcon)
        } label: {
          Label("More Options", systemImage: "ellipsis.circle")
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
      } else {
        selectFileButton
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
    
  @ViewBuilder
  private var selectFileButton: some View {
    Button {
      isImporterPresented = true
    } label: {
      Label("Select \(title)", systemImage: "doc.text.magnifyingglass")
    }
  }
  
  @ViewBuilder
  private var clearFileButton: some View {
    Button {
      file = nil
    } label: {
      Label("Clear", systemImage: "xmark.circle")
    }
  }
}

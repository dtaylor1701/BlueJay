#if os(macOS)
import Foundation
import Goose
import SwiftUI
import UniformTypeIdentifiers

public struct FileView: View {
  private let title: String
  private let allowedContentTypes: [UTType]

  @Binding
  private var file: File?

  @State
  private var isImporterPresented: Bool = false

  @State
  private var url: URL?

  public init(title: String, file: Binding<File?>, allowedContentTypes: [UTType]) {
    _file = file
    self.title = title
    self.allowedContentTypes = allowedContentTypes
  }

  public var body: some View {
    HStack {
      if file != nil {
        if let url {
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
    .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: allowedContentTypes) {
      result in
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
    .onChange(of: file?.bookmark) { _ in
      url = try? file?.url()
    }
    .task {
      url = try? file?.url()
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

#Preview {
  FileView(title: "Test file", file: Binding<File?>(get: {
    return nil
  }, set: { _ in
    
  }), allowedContentTypes: [.text])
  .padding()
}

#endif

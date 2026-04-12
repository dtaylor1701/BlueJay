#if os(macOS) || os(iOS)
  import Foundation
  import Goose
  import SwiftUI
  import UniformTypeIdentifiers

  #if os(macOS)
    import AppKit
  #endif

  /// A view for selecting and managing a `File`.
  ///
  /// `FileView` provides a button to trigger a file importer and shows the
  /// selected file's name with an option to clear it. On macOS, it also
  /// allows revealing the file in Finder.
  public struct FileView: View {
    private let title: String
    private let allowedContentTypes: [UTType]

    @Binding
    private var file: File?

    @State
    private var isImporterPresented: Bool = false

    @State
    private var url: URL?

    @State
    private var isResolving: Bool = false

    /// - Parameters:
    ///   - title: The name of the file type being selected (e.g., "Image").
    ///   - file: A binding to the optional `File` being managed.
    ///   - allowedContentTypes: The types of files that can be selected.
    public init(title: String, file: Binding<File?>, allowedContentTypes: [UTType]) {
      _file = file
      self.title = title
      self.allowedContentTypes = allowedContentTypes
    }

    public var body: some View {
      HStack {
        if file != nil {
          if let url {
            fileLabel(for: url)
          } else if isResolving {
            ProgressView()
              .controlSize(.small)
          } else {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.yellow)
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
      .fileImporter(
        isPresented: $isImporterPresented,
        allowedContentTypes: allowedContentTypes
      ) { result in
        switch result {
        case .success(let selectedUrl):
          do {
            let newFile = try File(at: selectedUrl)
            // Update both to maintain immediate consistency
            url = selectedUrl
            file = newFile
          } catch {
            BlueJayLog.view.error("Failed to create File from URL: \(error)")
          }
        case .failure(let error):
          BlueJayLog.view.error("File importer failed: \(error)")
        }
      }
      .task(id: file?.bookmark) {
        guard var resolvedFile = file else {
          url = nil
          isResolving = false
          return
        }

        // If current url already matches what we expect from file (identity-wise),
        // we might still want to resolve to be sure, but we can avoid flickering.
        isResolving = true
        do {
          url = try resolvedFile.resolveURL()
          // Update the binding if the file was modified (e.g. bookmark refreshed)
          if resolvedFile.bookmark != file?.bookmark {
            file = resolvedFile
          }
        } catch {
          BlueJayLog.view.error("Failed to resolve URL for file: \(error)")
          url = nil
        }
        isResolving = false
      }
    }

    @ViewBuilder
    private func fileLabel(for url: URL) -> some View {
      #if os(macOS)
        Button {
          NSWorkspace.shared.activateFileViewerSelecting([url])
        } label: {
          Text(url.lastPathComponent)
        }
        .buttonStyle(.link)
      #else
        Text(url.lastPathComponent)
          .font(.body)
      #endif
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
        url = nil
      } label: {
        Label("Clear", systemImage: "xmark.circle")
      }
    }
  }

  #Preview {
    FileView(
      title: "Test file",
      file: .constant(nil),
      allowedContentTypes: [.text]
    )
    .padding()
  }

#endif

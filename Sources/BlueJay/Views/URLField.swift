import Foundation
import SwiftUI

public struct URLField: View {
  @Binding private var url: URL?
  private let title: String
  private let openable: Bool

  @Environment(\.openURL) private var openURL

  private var textValue: Binding<String> {
    Binding {
      url?.absoluteString ?? ""
    } set: { newValue in
      if newValue.isEmpty {
        url = nil
      } else if var validComponents = URLComponents(string: newValue) {
        if validComponents.scheme == nil {
          // If there is no scheme, assume an https URL and re-parse to gather the host.
          validComponents = URLComponents(string: "https://\(newValue)")!
        }
        url = validComponents.url
      } else {
        url = nil
      }
    }
  }

  public init(_ title: String, url: Binding<URL?>, openable: Bool = true) {
    self.title = title
    self._url = url
    self.openable = openable
  }

  public var body: some View {
    HStack {
      TextField(title, text: textValue)
      if openable {
        Button {
          if let url {
            openURL(url)
          }
        } label: {
          Label("Open", systemImage: "arrow.right.circle")
            .labelStyle(.iconOnly)
        }
        #if os(macOS)
        .buttonStyle(.link)
        #else
        .buttonStyle(.plain).tint(.blue)
        #endif
        .disabled(url == nil)
      }
    }
  }
}

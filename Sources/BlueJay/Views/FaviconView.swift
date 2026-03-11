import SwiftUI

/// A view that fetches and displays the favicon for a given URL.
///
/// It uses a third-party service (Google's favicon API) to retrieve the icon
/// and provides a fallback globe icon if the favicon cannot be fetched.
public struct FaviconView: View {
  private let url: URL?

  @State private var imageData: Data?

  /// - Parameter url: The URL for which to display the favicon.
  public init(url: URL?) {
    self.url = url
  }

  @ViewBuilder
  private var image: some View {
    if let imageData {
      Image(data: imageData)
        .resizable()
    } else {
      Image(systemName: "globe")
        .resizable()
    }
  }

  public var body: some View {
    GeometryReader { proxy in
      image
        .frame(width: proxy.size.width, height: proxy.size.height)
        .task {
          await fetchFavicon()
        }
    }
  }

  private func fetchFavicon() async {
    guard let url else { return }

    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    guard let host = components?.host,
      let faviconURL = URL(
        string: "https://www.google.com/s2/favicons?sz=\(256)&domain_url=\(host)")
    else { return }

    let response = try? await URLSession.shared.data(from: faviconURL)
    self.imageData = response?.0
  }
}

#Preview {
  FaviconView(url: URL(string: "https://www.google.com")!)
}

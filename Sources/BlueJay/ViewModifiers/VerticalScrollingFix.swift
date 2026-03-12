import SwiftUI

public extension View {
  /// Applies a workaround for a vertical scrolling bug in macOS where nested scroll views may not scroll properly.
  @ViewBuilder func workaroundForVerticalScrollingBugInMacOS() -> some View {
    #if os(macOS)
    VerticalScrollingFixWrapper { self }
    #else
    self
    #endif
  }
}

#if os(macOS)
import AppKit

/// An NSView that implements proper `wantsForwardedScrollEvents` to allow vertical scrolling to propagate correctly.
final class VerticalScrollingFixHostingView<Content>: NSHostingView<Content> where Content: View {
  override func wantsForwardedScrollEvents(for axis: NSEvent.GestureAxis) -> Bool {
    return axis == .vertical
  }
}

/// A SwiftUI wrapper for `VerticalScrollingFixHostingView`.
struct VerticalScrollingFixViewRepresentable<Content>: NSViewRepresentable where Content: View {
  let content: Content

  func makeNSView(context: Context) -> NSHostingView<Content> {
    return VerticalScrollingFixHostingView<Content>(rootView: content)
  }

  func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {}
}

/// A SwiftUI wrapper that makes it easy to apply the vertical scrolling fix.
struct VerticalScrollingFixWrapper<Content>: View where Content : View {
  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    VerticalScrollingFixViewRepresentable(content: self.content())
  }
}
#endif

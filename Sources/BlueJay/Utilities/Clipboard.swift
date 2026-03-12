#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A utility for interacting with the system clipboard.
public struct Clipboard {
  /// Copies the provided text to the system clipboard.
  /// - Parameter text: The text to be copied.
  public static func copy(_ text: String) {
    #if canImport(AppKit)
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(text, forType: .string)
    #elseif canImport(UIKit)
    UIPasteboard.general.string = text
    #endif
  }
}

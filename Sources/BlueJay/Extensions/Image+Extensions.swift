import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension Image {
  /// Creates a SwiftUI `Image` from data.
  init(data: Data) {
#if canImport(UIKit)
    if let image = UIImage(data: data) {
      self.init(uiImage: image)
      return
    }
#elseif canImport(AppKit)
    if let image = NSImage(data: data) {
      self.init(nsImage: image)
      return
    }
#endif
    self.init(systemName: "questionmark.circle.fill")
  }
}

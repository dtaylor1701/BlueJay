import SwiftUI

public extension Color {
  /// A standard background color for content areas.
  ///
  /// This attempts to load a color named "ContentBackground" from the asset catalog.
  /// If not found, it falls back to a default system gray color.
  static let contentBackground: Color = Color("ContentBackground", bundle: .module)
}

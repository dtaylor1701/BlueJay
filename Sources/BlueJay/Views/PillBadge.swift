import SwiftUI

/// A compact, capsule-shaped badge that displays a short label with an optional leading icon.
///
/// The badge renders with a translucent tinted background and matching foreground text,
/// making it suitable for status indicators, priority labels, and categorical tags.
///
/// ```swift
/// PillBadge(text: "High", icon: "arrow.up", color: .orange)
/// ```
public struct PillBadge: View {
    /// The text displayed inside the badge.
    public let text: String

    /// An optional SF Symbol name displayed before the text.
    public let icon: String?

    /// The tint color used for the foreground and translucent background.
    public let color: Color

    /// The font for the label; the icon uses the same size.
    public let font: Font

    /// Opacity of the tinted background behind the label.
    public let backgroundOpacity: Double

    /// Creates a pill badge.
    ///
    /// - Parameters:
    ///   - text: The label to display.
    ///   - icon: An optional SF Symbol name for a leading icon. Defaults to `nil`.
    ///   - color: The tint color for both the text and the translucent background.
    ///   - font: The label font. Defaults to semibold `caption2`.
    ///   - backgroundOpacity: Opacity of the tinted background. Defaults to `0.2`.
    public init(
        text: String,
        icon: String? = nil,
        color: Color,
        font: Font = .caption2.weight(.semibold),
        backgroundOpacity: Double = 0.2
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.font = font
        self.backgroundOpacity = backgroundOpacity
    }

    public var body: some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(font)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(backgroundOpacity))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}

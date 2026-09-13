import Foundation

/// Represents a CommonMark header level (H1 through H6).
public enum MarkdownHeaderLevel: Int, CaseIterable, Identifiable, Sendable {
    /// Level 1 heading (`#`).
    case h1 = 1
    /// Level 2 heading (`##`).
    case h2 = 2
    /// Level 3 heading (`###`).
    case h3 = 3
    /// Level 4 heading (`####`).
    case h4 = 4
    /// Level 5 heading (`#####`).
    case h5 = 5
    /// Level 6 heading (`######`).
    case h6 = 6

    public var id: Int { rawValue }

    /// The Markdown formatting prefix including the trailing space (e.g., `## ` for `h2`).
    public var prefix: String {
        String(repeating: "#", count: rawValue) + " "
    }

    /// Initializes a header level by clamping any integer into the valid range `1...6`.
    ///
    /// - Parameter level: The integer level to clamp.
    public init(clamping level: Int) {
        let clamped = max(1, min(6, level))
        self = MarkdownHeaderLevel(rawValue: clamped) ?? .h2
    }
}

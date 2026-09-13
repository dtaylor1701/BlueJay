import Foundation

/// Metric statistics for a Markdown document.
public struct MarkdownDocumentStatistics: Equatable, Sendable {
    /// Number of lines in the document. An empty document has 0 lines.
    public let lines: Int

    /// Number of words separated by whitespace or line breaks.
    public let words: Int

    /// Number of extended grapheme clusters (characters) in the document.
    public let characters: Int

    /// An empty statistics instance with zero counts.
    public static let empty = MarkdownDocumentStatistics(lines: 0, words: 0, characters: 0)

    /// Initializes a statistics instance with explicit counts.
    public init(lines: Int, words: Int, characters: Int) {
        self.lines = lines
        self.words = words
        self.characters = characters
    }

    /// Computes statistics by analyzing a source text string.
    ///
    /// - Parameter text: The string content to analyze.
    public init(text: String) {
        if text.isEmpty {
            self = .empty
            return
        }

        // Count lines safely preserving trailing empty lines
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        self.lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).count
        self.words = text.split { $0.isWhitespace || $0.isNewline }.count
        self.characters = text.count
    }
}

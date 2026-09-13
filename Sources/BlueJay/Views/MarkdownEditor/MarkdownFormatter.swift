import Foundation

/// Pure functional formatting helpers for constructing and transforming Markdown text.
public enum MarkdownFormatter {

    /// Appends a heading prefix at the end of the text with appropriate newline separation.
    ///
    /// - Parameters:
    ///   - level: The integer heading level. Clamped to `1...6`.
    ///   - text: The current document string.
    /// - Returns: The updated document string with the heading prefix appended.
    public static func appendHeader(level: Int = 2, to text: String) -> String {
        let headerLevel = MarkdownHeaderLevel(clamping: level)
        return appendHeader(headerLevel, to: text)
    }

    /// Appends a strongly-typed heading prefix at the end of the text with appropriate newline separation.
    ///
    /// - Parameters:
    ///   - level: The strongly-typed `MarkdownHeaderLevel`.
    ///   - text: The current document string.
    /// - Returns: The updated document string with the heading prefix appended.
    public static func appendHeader(_ level: MarkdownHeaderLevel, to text: String) -> String {
        let prefix = level.prefix
        if text.isEmpty { return prefix }
        let separator = text.hasSuffix("\n\n") ? "" : (text.hasSuffix("\n") ? "\n" : "\n\n")
        return text + separator + prefix
    }

    /// Appends a bullet list item prefix at the end of the text.
    ///
    /// - Parameter text: The current document string.
    /// - Returns: The updated document string with `- ` appended.
    public static func appendBullet(to text: String) -> String {
        if text.isEmpty { return "- " }
        let separator = text.hasSuffix("\n") ? "" : "\n"
        return text + separator + "- "
    }

    /// Appends a checklist item prefix at the end of the text.
    ///
    /// - Parameter text: The current document string.
    /// - Returns: The updated document string with `- [ ] ` appended.
    public static func appendChecklist(to text: String) -> String {
        if text.isEmpty { return "- [ ] " }
        let separator = text.hasSuffix("\n") ? "" : "\n"
        return text + separator + "- [ ] "
    }

    /// Appends a blockquote prefix at the end of the text, ensuring a paragraph break to prevent CommonMark lazy continuation.
    ///
    /// - Parameter text: The current document string.
    /// - Returns: The updated document string with `> ` appended.
    public static func appendBlockquote(to text: String) -> String {
        if text.isEmpty { return "> " }
        let separator = text.hasSuffix("\n\n") ? "" : (text.hasSuffix("\n") ? "\n" : "\n\n")
        return text + separator + "> "
    }

    /// Appends a fenced code block with a specified language.
    ///
    /// - Parameters:
    ///   - text: The current document string.
    ///   - language: The syntax language identifier (e.g. `swift`, `json`).
    /// - Returns: The updated document string containing the fenced code block.
    public static func appendCodeBlock(to text: String, language: String = "swift") -> String {
        let block = "```\(language)\n\n```"
        if text.isEmpty { return block }
        let separator = text.hasSuffix("\n\n") ? "" : (text.hasSuffix("\n") ? "\n" : "\n\n")
        return text + separator + block
    }

    /// Appends a Markdown link.
    ///
    /// - Parameters:
    ///   - text: The current document string.
    ///   - title: The displayed link anchor text.
    ///   - url: The target URL string.
    /// - Returns: The updated document string with the link appended.
    public static func appendLink(to text: String, title: String = "link title", url: String = "https://example.com") -> String {
        let link = "[\(title)](\(url))"
        if text.isEmpty { return link }
        let separator = text.hasSuffix(" ") || text.hasSuffix("\n") ? "" : " "
        return text + separator + link
    }

    /// Wraps text in bold Markdown syntax (`**text**`), trimming whitespace to comply with CommonMark delimiter rules.
    ///
    /// - Parameter text: The string to format.
    /// - Returns: The wrapped bold string, or `"**bold text**"` if empty.
    public static func wrapBold(to text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "**bold text**" }
        return "**\(trimmed)**"
    }

    /// Wraps text in italic Markdown syntax (`*text*`), trimming whitespace to comply with CommonMark delimiter rules.
    ///
    /// - Parameter text: The string to format.
    /// - Returns: The wrapped italic string, or `"*italic text*"` if empty.
    public static func wrapItalic(to text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "*italic text*" }
        return "*\(trimmed)*"
    }

    /// Replaces or surrounds a specific text slice with a formatted transformation.
    ///
    /// - Parameters:
    ///   - text: The mutable document string.
    ///   - range: The character range to transform.
    ///   - transform: A closure that takes the selected substring and returns the replacement.
    /// - Returns: The new character range of the inserted replacement.
    @discardableResult
    public static func formatRange(
        in text: inout String,
        range: Range<String.Index>,
        using transform: (String) -> String
    ) -> Range<String.Index> {
        let selectedSubstring = String(text[range])
        let replacement = transform(selectedSubstring)
        text.replaceSubrange(range, with: replacement)
        let newEnd = text.index(range.lowerBound, offsetBy: replacement.count)
        return range.lowerBound..<newEnd
    }
}

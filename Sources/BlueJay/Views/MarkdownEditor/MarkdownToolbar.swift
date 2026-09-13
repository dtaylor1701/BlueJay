import SwiftUI

/// Pure formatting helpers for manipulating markdown text.
public enum MarkdownFormatter {
    public static func appendHeader(level: Int = 2, to text: String) -> String {
        let prefix = String(repeating: "#", count: level) + " "
        if text.isEmpty { return prefix }
        let separator = text.hasSuffix("\n\n") ? "" : (text.hasSuffix("\n") ? "\n" : "\n\n")
        return text + separator + prefix
    }

    public static func appendBullet(to text: String) -> String {
        if text.isEmpty { return "- " }
        let separator = text.hasSuffix("\n") ? "" : "\n"
        return text + separator + "- "
    }

    public static func appendChecklist(to text: String) -> String {
        if text.isEmpty { return "- [ ] " }
        let separator = text.hasSuffix("\n") ? "" : "\n"
        return text + separator + "- [ ] "
    }

    public static func appendBlockquote(to text: String) -> String {
        if text.isEmpty { return "> " }
        let separator = text.hasSuffix("\n") ? "" : "\n"
        return text + separator + "> "
    }

    public static func appendCodeBlock(to text: String, language: String = "swift") -> String {
        let block = "```\(language)\n\n```"
        if text.isEmpty { return block }
        let separator = text.hasSuffix("\n\n") ? "" : (text.hasSuffix("\n") ? "\n" : "\n\n")
        return text + separator + block
    }

    public static func appendLink(to text: String, title: String = "link title", url: String = "https://example.com") -> String {
        let link = "[\(title)](\(url))"
        if text.isEmpty { return link }
        let separator = text.hasSuffix(" ") || text.hasSuffix("\n") ? "" : " "
        return text + separator + link
    }

    public static func wrapBold(to text: String) -> String {
        "**\(text)**"
    }

    public static func wrapItalic(to text: String) -> String {
        "*\(text)*"
    }
}

/// A lightweight formatting toolbar for inserting common markdown structures.
public struct MarkdownToolbar: View {
    @Binding var text: String

    public init(text: Binding<String>) {
        self._text = text
    }

    public var body: some View {
        HStack(spacing: 4) {
            Button {
                text = MarkdownFormatter.appendHeader(level: 2, to: text)
            } label: {
                Label("Heading", systemImage: "number")
            }
            .help("Insert Heading (##)")

            Button {
                text += "**bold text**"
            } label: {
                Label("Bold", systemImage: "bold")
            }
            .help("Insert Bold (**text**)")

            Button {
                text += "*italic text*"
            } label: {
                Label("Italic", systemImage: "italic")
            }
            .help("Insert Italic (*text*)")

            Divider()
                .frame(height: 16)

            Button {
                text = MarkdownFormatter.appendBullet(to: text)
            } label: {
                Label("Bullet List", systemImage: "list.bullet")
            }
            .help("Insert Bullet List (- item)")

            Button {
                text = MarkdownFormatter.appendChecklist(to: text)
            } label: {
                Label("Checklist", systemImage: "checklist")
            }
            .help("Insert Checklist Item (- [ ])")

            Divider()
                .frame(height: 16)

            Button {
                text = MarkdownFormatter.appendCodeBlock(to: text)
            } label: {
                Label("Code Block", systemImage: "curlybraces")
            }
            .help("Insert Code Block (```)")

            Button {
                text = MarkdownFormatter.appendBlockquote(to: text)
            } label: {
                Label("Quote", systemImage: "quote.opening")
            }
            .help("Insert Blockquote (>)")

            Button {
                text = MarkdownFormatter.appendLink(to: text)
            } label: {
                Label("Link", systemImage: "link")
            }
            .help("Insert Markdown Link ([title](url))")
        }
        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)
        .controlSize(.small)
    }
}

import SwiftUI

/// A lightweight formatting toolbar for inserting and formatting Markdown structures.
@MainActor
public struct MarkdownToolbar: View {
    @Binding var text: String
    private var selection: Binding<TextSelection?>?

    /// Initializes a Markdown formatting toolbar.
    ///
    /// - Parameters:
    ///   - text: A binding to the document string.
    ///   - selection: An optional binding to the current text selection for cursor-aware insertions.
    public init(text: Binding<String>, selection: Binding<TextSelection?>? = nil) {
        self._text = text
        self.selection = selection
    }

    public var body: some View {
        HStack(spacing: 4) {
            Button {
                insertHeader()
            } label: {
                Label("Heading", systemImage: "number")
            }
            .help("Insert Heading (##)")

            Button {
                applyFormatting(
                    wrap: { MarkdownFormatter.wrapBold(to: $0) },
                    placeholder: "**bold text**"
                )
            } label: {
                Label("Bold", systemImage: "bold")
            }
            .help("Insert Bold (**text**)")

            Button {
                applyFormatting(
                    wrap: { MarkdownFormatter.wrapItalic(to: $0) },
                    placeholder: "*italic text*"
                )
            } label: {
                Label("Italic", systemImage: "italic")
            }
            .help("Insert Italic (*text*)")

            Divider()
                .frame(height: 16)

            Button {
                insertPrefix("- ")
            } label: {
                Label("Bullet List", systemImage: "list.bullet")
            }
            .help("Insert Bullet List (- item)")

            Button {
                insertPrefix("- [ ] ")
            } label: {
                Label("Checklist", systemImage: "checklist")
            }
            .help("Insert Checklist Item (- [ ])")

            Divider()
                .frame(height: 16)

            Button {
                insertCodeBlock()
            } label: {
                Label("Code Block", systemImage: "curlybraces")
            }
            .help("Insert Code Block (```)")

            Button {
                insertPrefix("> ")
            } label: {
                Label("Quote", systemImage: "quote.opening")
            }
            .help("Insert Blockquote (>)")

            Button {
                insertLink()
            } label: {
                Label("Link", systemImage: "link")
            }
            .help("Insert Markdown Link ([title](url))")
        }
        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)
        .controlSize(.small)
    }

    private func applyFormatting(wrap: (String) -> String, placeholder: String) {
        if let binding = selection, let sel = binding.wrappedValue, case .selection(let range) = sel.indices {
            if range.isEmpty {
                // Insert at caret
                text.insert(contentsOf: placeholder, at: range.lowerBound)
                let newEnd = text.index(range.lowerBound, offsetBy: placeholder.count)
                binding.wrappedValue = TextSelection(range: range.lowerBound..<newEnd)
            } else {
                // Wrap selection
                let sub = String(text[range])
                let wrapped = wrap(sub)
                text.replaceSubrange(range, with: wrapped)
                let newEnd = text.index(range.lowerBound, offsetBy: wrapped.count)
                binding.wrappedValue = TextSelection(range: range.lowerBound..<newEnd)
            }
        } else {
            text += (text.isEmpty || text.hasSuffix(" ") || text.hasSuffix("\n") ? "" : " ") + placeholder
        }
    }

    private func insertHeader() {
        if let binding = selection, let sel = binding.wrappedValue, case .selection(let range) = sel.indices {
            let prefix = "## "
            text.insert(contentsOf: prefix, at: range.lowerBound)
            let newEnd = text.index(range.lowerBound, offsetBy: prefix.count)
            binding.wrappedValue = TextSelection(range: newEnd..<newEnd)
        } else {
            text = MarkdownFormatter.appendHeader(level: 2, to: text)
        }
    }

    private func insertPrefix(_ prefix: String) {
        if let binding = selection, let sel = binding.wrappedValue, case .selection(let range) = sel.indices {
            text.insert(contentsOf: prefix, at: range.lowerBound)
            let newEnd = text.index(range.lowerBound, offsetBy: prefix.count)
            binding.wrappedValue = TextSelection(range: newEnd..<newEnd)
        } else {
            let separator = text.isEmpty ? "" : (text.hasSuffix("\n") ? "" : "\n")
            text += separator + prefix
        }
    }

    private func insertCodeBlock() {
        if let binding = selection, let sel = binding.wrappedValue, case .selection(let range) = sel.indices {
            if !range.isEmpty {
                let code = String(text[range])
                let block = "```swift\n\(code)\n```"
                text.replaceSubrange(range, with: block)
                let newEnd = text.index(range.lowerBound, offsetBy: block.count)
                binding.wrappedValue = TextSelection(range: range.lowerBound..<newEnd)
                return
            }
        }
        text = MarkdownFormatter.appendCodeBlock(to: text)
    }

    private func insertLink() {
        if let binding = selection, let sel = binding.wrappedValue, case .selection(let range) = sel.indices, !range.isEmpty {
            let title = String(text[range])
            let link = "[\(title)](https://example.com)"
            text.replaceSubrange(range, with: link)
            let newEnd = text.index(range.lowerBound, offsetBy: link.count)
            binding.wrappedValue = TextSelection(range: range.lowerBound..<newEnd)
        } else {
            text = MarkdownFormatter.appendLink(to: text)
        }
    }
}

import SwiftUI
import Markdown

/// A native SwiftUI view that parses and renders CommonMark and GitHub Flavored Markdown using Apple's `swift-markdown` AST.
public struct MarkdownRenderer: View {
    private let markdown: String

    /// Initializes a markdown renderer with raw markdown text.
    ///
    /// - Parameter markdown: The Markdown string to parse and render.
    public init(markdown: String) {
        self.markdown = markdown
    }

    public var body: some View {
        let trimmed = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            Text("No content to preview.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            let document = Document(parsing: markdown)
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(document.children.enumerated()), id: \.offset) { _, block in
                    renderBlock(block)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func renderBlock(_ markup: Markup) -> AnyView {
        if let heading = markup as? Heading {
            return AnyView(renderHeading(heading))
        } else if let paragraph = markup as? Paragraph {
            return AnyView(renderParagraph(paragraph))
        } else if let codeBlock = markup as? CodeBlock {
            return AnyView(renderCodeBlock(codeBlock))
        } else if let blockQuote = markup as? BlockQuote {
            return AnyView(renderBlockQuote(blockQuote))
        } else if let list = markup as? UnorderedList {
            return AnyView(renderUnorderedList(list))
        } else if let list = markup as? OrderedList {
            return AnyView(renderOrderedList(list))
        } else if markup is ThematicBreak {
            return AnyView(Divider().padding(.vertical, 4))
        } else if let table = markup as? Markdown.Table {
            return AnyView(renderTable(table))
        } else {
            // Fallback for custom or unhandled block elements
            return AnyView(
                Text(markup.format())
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        }
    }

    @ViewBuilder
    private func renderHeading(_ heading: Heading) -> some View {
        let text = inlineContent(of: heading)
        switch heading.level {
        case 1:
            Text(text)
                .font(.largeTitle.bold())
        case 2:
            Text(text)
                .font(.title2.bold())
        case 3:
            Text(text)
                .font(.title3.bold())
        case 4:
            Text(text)
                .font(.headline)
        case 5:
            Text(text)
                .font(.subheadline.bold())
        default:
            Text(text)
                .font(.callout.bold())
        }
    }

    @ViewBuilder
    private func renderParagraph(_ paragraph: Paragraph) -> some View {
        Text(inlineContent(of: paragraph))
            .font(.body)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func renderCodeBlock(_ codeBlock: CodeBlock) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let language = codeBlock.language, !language.isEmpty {
                HStack {
                    Text(language.uppercased())
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(codeBlock.code)
                    .font(.system(.callout, design: .monospaced))
                    .padding(10)
            }
        }
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func renderBlockQuote(_ blockQuote: BlockQuote) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accentColor.opacity(0.7))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                    renderBlock(child)
                }
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func renderUnorderedList(_ list: UnorderedList) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(list.listItems.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    if let checkbox = item.checkbox {
                        Image(systemName: checkbox == .checked ? "checkmark.square.fill" : "square")
                            .foregroundStyle(checkbox == .checked ? Color.accentColor : Color.secondary)
                            .font(.callout)
                    } else {
                        Text("•")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(item.children.enumerated()), id: \.offset) { _, child in
                            renderBlock(child)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func renderOrderedList(_ list: OrderedList) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(list.listItems.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(item.children.enumerated()), id: \.offset) { _, child in
                            renderBlock(child)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func renderTable(_ table: Markdown.Table) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    ForEach(Array(table.head.cells.enumerated()), id: \.offset) { _, cell in
                        Text(inlineContent(of: cell))
                            .font(.headline)
                    }
                }
                Divider()

                ForEach(Array(table.body.rows.enumerated()), id: \.offset) { _, row in
                    GridRow {
                        ForEach(Array(row.cells.enumerated()), id: \.offset) { _, cell in
                            Text(inlineContent(of: cell))
                                .font(.body)
                        }
                    }
                }
            }
            .padding(10)
            .background(Color.secondary.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    /// Renders inline markdown elements to an `AttributedString`.
    private func inlineContent(of markup: Markup) -> AttributedString {
        var result = AttributedString()
        for child in markup.children {
            result.append(renderInline(child))
        }
        return result
    }

    private func renderInline(_ markup: Markup) -> AttributedString {
        if let textNode = markup as? Markdown.Text {
            return AttributedString(textNode.string)
        } else if let strong = markup as? Strong {
            var str = inlineContent(of: strong)
            str.inlinePresentationIntent = (str.inlinePresentationIntent ?? []).union(.stronglyEmphasized)
            return str
        } else if let emphasis = markup as? Emphasis {
            var str = inlineContent(of: emphasis)
            str.inlinePresentationIntent = (str.inlinePresentationIntent ?? []).union(.emphasized)
            return str
        } else if let inlineCode = markup as? InlineCode {
            var str = AttributedString(inlineCode.code)
            str.inlinePresentationIntent = (str.inlinePresentationIntent ?? []).union(.code)
            return str
        } else if let link = markup as? Markdown.Link {
            var str = inlineContent(of: link)
            if let dest = link.destination, let url = URL(string: dest) {
                str.link = url
            }
            return str
        } else if markup is SoftBreak {
            return AttributedString(" ")
        } else if markup is LineBreak {
            return AttributedString("\n")
        } else {
            return AttributedString(markup.format())
        }
    }
}

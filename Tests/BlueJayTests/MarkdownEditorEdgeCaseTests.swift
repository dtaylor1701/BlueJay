import Testing
@testable import BlueJay

@Suite("Markdown Formatter Edge Cases & Robustness")
struct MarkdownEditorEdgeCaseTests {

    @Test("Header level boundaries (negative, zero, overflow)", arguments: [
        (-10, "# "),
        (-1, "# "),
        (0, "# "),
        (1, "# "),
        (2, "## "),
        (5, "##### "),
        (6, "###### "),
        (7, "###### "),
        (100, "###### ")
    ])
    func testHeaderBoundaries(level: Int, expectedPrefix: String) {
        let result = MarkdownFormatter.appendHeader(level: level, to: "")
        #expect(result == expectedPrefix)
    }

    @Test("Header level strongly typed enum prefixes")
    func testHeaderLevelEnum() {
        #expect(MarkdownHeaderLevel.h1.prefix == "# ")
        #expect(MarkdownHeaderLevel.h2.prefix == "## ")
        #expect(MarkdownHeaderLevel.h3.prefix == "### ")
        #expect(MarkdownHeaderLevel.h4.prefix == "#### ")
        #expect(MarkdownHeaderLevel.h5.prefix == "##### ")
        #expect(MarkdownHeaderLevel.h6.prefix == "###### ")

        #expect(MarkdownHeaderLevel(clamping: -5) == .h1)
        #expect(MarkdownHeaderLevel(clamping: 0) == .h1)
        #expect(MarkdownHeaderLevel(clamping: 3) == .h3)
        #expect(MarkdownHeaderLevel(clamping: 99) == .h6)
    }

    @Test("Header appends with multiline text and varying newlines")
    func testHeaderMultilineSpacing() {
        #expect(MarkdownFormatter.appendHeader(level: 2, to: "Line 1") == "Line 1\n\n## ")
        #expect(MarkdownFormatter.appendHeader(level: 2, to: "Line 1\n") == "Line 1\n\n## ")
        #expect(MarkdownFormatter.appendHeader(level: 2, to: "Line 1\n\n") == "Line 1\n\n## ")
        #expect(MarkdownFormatter.appendHeader(level: 2, to: "Line 1\n\n\n") == "Line 1\n\n\n## ")
    }

    @Test("Bullet list spacing on trailing newlines and whitespace")
    func testBulletListEdgeCases() {
        #expect(MarkdownFormatter.appendBullet(to: "") == "- ")
        #expect(MarkdownFormatter.appendBullet(to: "Item 1") == "Item 1\n- ")
        #expect(MarkdownFormatter.appendBullet(to: "Item 1\n") == "Item 1\n- ")
        #expect(MarkdownFormatter.appendBullet(to: "Item 1\n\n") == "Item 1\n\n- ")
    }

    @Test("Blockquote paragraph separation prevents lazy continuation")
    func testBlockquoteSeparation() {
        #expect(MarkdownFormatter.appendBlockquote(to: "") == "> ")
        #expect(MarkdownFormatter.appendBlockquote(to: "Paragraph") == "Paragraph\n\n> ")
        #expect(MarkdownFormatter.appendBlockquote(to: "Paragraph\n") == "Paragraph\n\n> ")
        #expect(MarkdownFormatter.appendBlockquote(to: "Paragraph\n\n") == "Paragraph\n\n> ")
    }

    @Test("Bold and italic formatting with empty and whitespace strings")
    func testWrapFormattingEdgeCases() {
        #expect(MarkdownFormatter.wrapBold(to: "") == "**bold text**")
        #expect(MarkdownFormatter.wrapBold(to: "   ") == "**bold text**")
        #expect(MarkdownFormatter.wrapBold(to: "  word  ") == "**word**")

        #expect(MarkdownFormatter.wrapItalic(to: "") == "*italic text*")
        #expect(MarkdownFormatter.wrapItalic(to: "   ") == "*italic text*")
        #expect(MarkdownFormatter.wrapItalic(to: "  word  ") == "*word*")
    }

    @Test("Code block with custom or blank language")
    func testCodeBlockLanguages() {
        #expect(MarkdownFormatter.appendCodeBlock(to: "", language: "") == "```\n\n```")
        #expect(MarkdownFormatter.appendCodeBlock(to: "Intro", language: "json") == "Intro\n\n```json\n\n```")
    }

    @Test("Format range transformation inout helper")
    func testFormatRange() {
        var doc = "Hello world!"
        let start = doc.index(doc.startIndex, offsetBy: 6)
        let end = doc.index(doc.startIndex, offsetBy: 11)
        let newRange = MarkdownFormatter.formatRange(in: &doc, range: start..<end) {
            MarkdownFormatter.wrapBold(to: $0)
        }
        #expect(doc == "Hello **world**!")
        #expect(String(doc[newRange]) == "**world**")
    }
}

@Suite("Markdown Document Statistics Tests")
struct MarkdownDocumentStatisticsTests {

    @Test("Empty document reports zero counts")
    func testEmptyDocument() {
        let stats = MarkdownDocumentStatistics(text: "")
        #expect(stats.lines == 0)
        #expect(stats.words == 0)
        #expect(stats.characters == 0)
        #expect(stats == .empty)
    }

    @Test("Whitespace and newlines counting")
    func testWhitespaceDocument() {
        let stats = MarkdownDocumentStatistics(text: "   \n\n   ")
        #expect(stats.lines == 3)
        #expect(stats.words == 0)
        #expect(stats.characters == 8)
    }

    @Test("CRLF Windows line endings are counted properly")
    func testCRLFLineEndings() {
        let stats = MarkdownDocumentStatistics(text: "Line 1\r\nLine 2\r\nLine 3")
        #expect(stats.lines == 3)
        #expect(stats.words == 6)
    }

    @Test("Multi-line text with trailing newline")
    func testMultilineText() {
        let stats = MarkdownDocumentStatistics(text: "First line\nSecond line\n")
        #expect(stats.lines == 3)
        #expect(stats.words == 4)
        #expect(stats.characters == 23)
    }

    @Test("Unicode emojis and grapheme clusters")
    func testUnicodeAndEmojis() {
        let stats = MarkdownDocumentStatistics(text: "Hello 👨‍👩‍👧‍👦 🎉")
        #expect(stats.lines == 1)
        #expect(stats.words == 3)
        #expect(stats.characters == 9)
    }
}

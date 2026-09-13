import Testing
@testable import BlueJay

@Suite("Markdown Editor Formatter Tests")
struct MarkdownEditorTests {
    @Test("Append header formatting")
    func testAppendHeader() {
        let empty = MarkdownFormatter.appendHeader(level: 1, to: "")
        #expect(empty == "# ")

        let existing = MarkdownFormatter.appendHeader(level: 2, to: "Introduction")
        #expect(existing == "Introduction\n\n## ")
    }

    @Test("Append bullet list item")
    func testAppendBullet() {
        let empty = MarkdownFormatter.appendBullet(to: "")
        #expect(empty == "- ")

        let existing = MarkdownFormatter.appendBullet(to: "First item")
        #expect(existing == "First item\n- ")
    }

    @Test("Append checklist task item")
    func testAppendChecklist() {
        let empty = MarkdownFormatter.appendChecklist(to: "")
        #expect(empty == "- [ ] ")

        let existing = MarkdownFormatter.appendChecklist(to: "Sprint items:")
        #expect(existing == "Sprint items:\n- [ ] ")
    }

    @Test("Append code block")
    func testAppendCodeBlock() {
        let result = MarkdownFormatter.appendCodeBlock(to: "Some code below", language: "swift")
        #expect(result.contains("```swift\n\n```"))
    }

    @Test("Append blockquote")
    func testAppendBlockquote() {
        let empty = MarkdownFormatter.appendBlockquote(to: "")
        #expect(empty == "> ")
    }

    @Test("Append link formatting")
    func testAppendLink() {
        let link = MarkdownFormatter.appendLink(to: "Check out", title: "Apple", url: "https://apple.com")
        #expect(link == "Check out [Apple](https://apple.com)")
    }

    @Test("Wrap bold and italic formatting")
    func testWrapStyles() {
        #expect(MarkdownFormatter.wrapBold(to: "BoldText") == "**BoldText**")
        #expect(MarkdownFormatter.wrapItalic(to: "ItalicText") == "*ItalicText*")
    }

    @Test("Editor modes have unique identifiers and icons")
    func testEditorModes() {
        let modes = MarkdownEditorMode.allCases
        #expect(modes.count == 3)
        #expect(Set(modes.map(\.id)).count == 3)
        #expect(Set(modes.map(\.iconName)).count == 3)
    }
}

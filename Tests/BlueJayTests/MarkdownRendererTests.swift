import SwiftUI
import Testing
@testable import BlueJay

@Suite("Markdown Renderer AST Tests")
struct MarkdownRendererTests {

    @Test("Renderer instantiates with empty string")
    @MainActor
    func testEmptyMarkdown() {
        let renderer = MarkdownRenderer(markdown: "")
        let _ = renderer.body
    }

    @Test("Renderer handles rich markdown blocks without runtime crashes")
    @MainActor
    func testRichMarkdownParsing() {
        let sample = """
        # Title H1
        ## Subtitle H2
        ### Section H3

        A paragraph with **bold text**, *italic text*, `inline code`, and [Apple](https://apple.com).

        > A blockquote with wisdom.

        ```swift
        let language = "Swift"
        print("Hello, \\(language)")
        ```

        - Regular item
        - [ ] Unchecked task
        - [x] Completed task

        1. Ordered first
        2. Ordered second

        ---

        | Header 1 | Header 2 |
        |---|---|
        | Cell 1 | Cell 2 |
        """

        let renderer = MarkdownRenderer(markdown: sample)
        let _ = renderer.body
    }
}

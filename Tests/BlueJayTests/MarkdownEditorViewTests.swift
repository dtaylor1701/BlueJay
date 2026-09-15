import SwiftUI
import Testing
@testable import BlueJay

@Suite("Markdown Editor View Default Mode Tests")
struct MarkdownEditorViewTests {

    @Test("Environment default mode defaults to split")
    func testEnvironmentDefaultMode() {
        #expect(MarkdownEditorDefaultModeKey.defaultValue == .split)

        var values = EnvironmentValues()
        #expect(values.markdownEditorDefaultMode == .split)

        values.markdownEditorDefaultMode = .preview
        #expect(values.markdownEditorDefaultMode == .preview)

        values.markdownEditorDefaultMode = .editor
        #expect(values.markdownEditorDefaultMode == .editor)
    }

    @Test("View modifier applies markdownEditorDefaultMode")
    @MainActor
    func testViewModifier() {
        let view = Text("Test").markdownEditorDefaultMode(.editor)
        let _ = view
    }

    @Test("MarkdownEditorView initializes with default parameters")
    @MainActor
    func testInitializationDefaults() {
        var text = "# Hello"
        let binding = Binding(get: { text }, set: { text = $0 })
        let editor = MarkdownEditorView(text: binding)

        #expect(editor.defaultMode == nil)
        #expect(editor.title == nil)
        let _ = editor.body
    }

    @Test("MarkdownEditorView initializes with explicit defaultMode")
    @MainActor
    func testInitializationWithExplicitDefaultMode() {
        var text = "# Hello"
        let binding = Binding(get: { text }, set: { text = $0 })

        let editorEditor = MarkdownEditorView(text: binding, defaultMode: .editor)
        #expect(editorEditor.defaultMode == .editor)
        let _ = editorEditor.body

        let editorPreview = MarkdownEditorView(text: binding, defaultMode: .preview)
        #expect(editorPreview.defaultMode == .preview)
        let _ = editorPreview.body

        let editorSplit = MarkdownEditorView(text: binding, defaultMode: .split)
        #expect(editorSplit.defaultMode == .split)
        let _ = editorSplit.body
    }

    @Test("MarkdownEditorView initializes with two-way isDirty and defaultMode")
    @MainActor
    func testInitializationWithDirtyBindingAndDefaultMode() {
        var text = "Content"
        let textBinding = Binding(get: { text }, set: { text = $0 })
        var isDirty = false
        let dirtyBinding = Binding(get: { isDirty }, set: { isDirty = $0 })

        let editor = MarkdownEditorView(
            text: textBinding,
            isDirty: dirtyBinding,
            title: "Notes",
            defaultMode: .preview
        )

        #expect(editor.defaultMode == .preview)
        #expect(editor.title == "Notes")
        let _ = editor.body
    }

    @Test("MarkdownEditorView initializes with external mode binding and defaultMode")
    @MainActor
    func testInitializationWithExternalModeBinding() {
        var text = "Content"
        let textBinding = Binding(get: { text }, set: { text = $0 })
        var mode = MarkdownEditorMode.split
        let modeBinding = Binding(get: { mode }, set: { mode = $0 })

        let editor = MarkdownEditorView(
            text: textBinding,
            mode: modeBinding,
            defaultMode: .editor
        )

        #expect(editor.defaultMode == .editor)
        let _ = editor.body
    }

    @Test("MarkdownEditorView uses idiomatic opticaldisc icon for save")
    @MainActor
    func testSaveIconName() {
        #expect(MarkdownEditorView.saveIconName == "opticaldisc")
    }

    @Test("MarkdownEditorView initializes with onSave callback and executes properly")
    @MainActor
    func testInitializationWithOnSave() {
        var text = "Content"
        let textBinding = Binding(get: { text }, set: { text = $0 })
        var saved = false

        let editor = MarkdownEditorView(
            text: textBinding,
            onSave: {
                saved = true
            }
        )

        #expect(editor.onSave != nil)
        let _ = editor.body
        editor.onSave?()
        #expect(saved == true)
    }
}

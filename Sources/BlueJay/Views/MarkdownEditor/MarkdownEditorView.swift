import SwiftUI
import Crow

/// A lightweight, reusable Markdown editor component with AST live preview, cursor-aware formatting toolbar, and split/editor/preview modes.
@MainActor
public struct MarkdownEditorView: View {
    @Binding public var text: String

    /// Optional document title displayed in the header bar.
    public let title: String?

    /// Optional default display mode used when no external mode binding is provided.
    public let defaultMode: MarkdownEditorMode?

    /// Optional save action closure executed on Save button tap or `Cmd+S`.
    public let onSave: (@MainActor @Sendable () -> Void)?

    /// SF Symbol icon name used for the save action button.
    nonisolated public static let saveIconName: String = "opticaldisc"

    @Environment(\.markdownEditorDefaultMode) private var environmentDefaultMode
    @State private var internalMode: MarkdownEditorMode? = nil
    private var externalMode: Binding<MarkdownEditorMode>?

    @State private var internalIsDirty: Bool = false
    @State private var initialText: String?
    private var externalIsDirty: Binding<Bool>?


    /// Initializes a Markdown editor view with an external dirty-state boolean.
    ///
    /// - Parameters:
    ///   - text: Binding to the Markdown document string.
    ///   - title: Optional document title.
    ///   - isDirty: Initial dirty state value (defaults to false). Edits will automatically update internal dirty state.
    ///   - mode: Optional external binding controlling the active editor display mode.
    ///   - defaultMode: Optional default display mode to use when no external mode binding is provided. Defaults to `.split` (via environment).
    ///   - onSave: Optional callback executed when the document is saved.
    public init(
        text: Binding<String>,
        title: String? = nil,
        isDirty: Bool = false,
        mode: Binding<MarkdownEditorMode>? = nil,
        defaultMode: MarkdownEditorMode? = nil,
        onSave: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self._text = text
        self.title = title
        self._internalIsDirty = State(initialValue: isDirty)
        self.externalMode = mode
        self.defaultMode = defaultMode
        self._internalMode = State(initialValue: nil)
        self.externalIsDirty = nil
        self.onSave = onSave
    }

    /// Initializes a Markdown editor view with a two-way dirty-state binding.
    ///
    /// - Parameters:
    ///   - text: Binding to the Markdown document string.
    ///   - isDirty: Two-way binding reflecting whether the document has unsaved modifications.
    ///   - title: Optional document title.
    ///   - mode: Optional external binding controlling the active editor display mode.
    ///   - defaultMode: Optional default display mode to use when no external mode binding is provided. Defaults to `.split` (via environment).
    ///   - onSave: Optional callback executed when the document is saved.
    public init(
        text: Binding<String>,
        isDirty: Binding<Bool>,
        title: String? = nil,
        mode: Binding<MarkdownEditorMode>? = nil,
        defaultMode: MarkdownEditorMode? = nil,
        onSave: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self._text = text
        self.title = title
        self._internalIsDirty = State(initialValue: isDirty.wrappedValue)
        self.externalMode = mode
        self.defaultMode = defaultMode
        self._internalMode = State(initialValue: nil)
        self.externalIsDirty = isDirty
        self.onSave = onSave
    }

    private var activeMode: Binding<MarkdownEditorMode> {
        if let externalMode {
            return externalMode
        }
        return Binding(
            get: {
                internalMode ?? defaultMode ?? environmentDefaultMode
            },
            set: { newMode in
                internalMode = newMode
            }
        )
    }

    private var isDirty: Bool {
        externalIsDirty?.wrappedValue ?? internalIsDirty
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar

            Divider()

            Group {
                switch activeMode.wrappedValue {
                case .editor:
                    editorPane
                case .preview:
                    previewPane
                case .split:
                    #if os(macOS)
                    HSplitView {
                        editorPane
                            .frame(minWidth: 100, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        previewPane
                            .frame(minWidth: 100, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    #else
                    HStack(spacing: 0) {
                        editorPane
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        Divider()
                        previewPane
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    #endif
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Divider()

            statusBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            if initialText == nil {
                initialText = text
            }
        }
        .onChange(of: text) { _, newText in
            if let initial = initialText {
                let dirty = (newText != initial)
                internalIsDirty = dirty
                externalIsDirty?.wrappedValue = dirty
            }
        }
        .onChange(of: activeMode.wrappedValue) { oldMode, newMode in
            Crow.debug("MarkdownEditor mode transitioned from \(oldMode.rawValue) to \(newMode.rawValue)")
        }
    }

    @ViewBuilder
    private var headerBar: some View {
        ViewThatFits(in: .horizontal) {
            // Wide single-line layout
            HStack(spacing: 12) {
                if let title = title {
                    titleView(title)
                }

                modePicker(labeled: true)
                    .frame(maxWidth: 240)

                Divider()
                    .frame(height: 18)

                MarkdownToolbar(text: $text)
                    .disabled(activeMode.wrappedValue == .preview)

                Spacer()

                if let onSave = onSave {
                    saveButton(action: onSave, labeled: true)
                }
            }

            // Medium two-line layout with labeled mode picker
            twoLineHeader(labeled: true, spacing: 8)

            // Compact two-line layout with icon-only controls
            twoLineHeader(labeled: false, spacing: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.06))
    }

    @ViewBuilder
    private func twoLineHeader(labeled: Bool, spacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: spacing) {
                if let title = title {
                    titleView(title)
                }

                modePicker(labeled: labeled)

                Spacer()

                if let onSave = onSave {
                    saveButton(action: onSave, labeled: labeled)
                }
            }

            MarkdownToolbar(text: $text)
                .disabled(activeMode.wrappedValue == .preview)
        }
    }

    @ViewBuilder
    private func titleView(_ title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            Circle()
                .fill(Color.orange)
                .frame(width: 7, height: 7)
                .opacity(isDirty ? 1.0 : 0.0)
                .help(isDirty ? "Unsaved changes" : "")
                .accessibilityLabel(isDirty ? "Unsaved changes" : "")
        }
    }

    @ViewBuilder
    private func modePicker(labeled: Bool) -> some View {
        Picker("Editor Mode", selection: activeMode) {
            ForEach(MarkdownEditorMode.allCases) { mode in
                if labeled {
                    Label(mode.rawValue, systemImage: mode.iconName).tag(mode)
                } else {
                    Image(systemName: mode.iconName)
                        .tag(mode)
                        .help(mode.rawValue)
                        .accessibilityLabel(mode.rawValue)
                }
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    @ViewBuilder
    private func saveButton(action onSave: @escaping @MainActor @Sendable () -> Void, labeled: Bool) -> some View {
        Button {
            Crow.info("Markdown document saved (\(text.count) characters)")
            initialText = text
            internalIsDirty = false
            externalIsDirty?.wrappedValue = false
            onSave()
        } label: {
            if labeled {
                Label("Save", systemImage: Self.saveIconName)
            } else {
                Image(systemName: Self.saveIconName)
                    .accessibilityLabel("Save")
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
        .keyboardShortcut("s", modifiers: .command)
        .disabled(!isDirty)
        .help("Save changes (Cmd+S)")
    }

    @ViewBuilder
    private var editorPane: some View {
        TextEditor(text: $text)
            .font(.system(.body, design: .monospaced))
            .padding(12)
            .scrollContentBackground(.hidden)
            .background(Color.primary.opacity(0.02))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var previewPane: some View {
        ScrollView {
            MarkdownRenderer(markdown: text)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.secondary.opacity(0.03))
    }

    @ViewBuilder
    private var statusBar: some View {
        let stats = MarkdownDocumentStatistics(text: text)

        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                Text("\(stats.lines) lines • \(stats.words) words • \(stats.characters) chars")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                dirtyIndicator
            }

            HStack(spacing: 8) {
                Text("\(stats.words)w • \(stats.lines)l")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                dirtyIndicator
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.04))
    }

    @ViewBuilder
    private var dirtyIndicator: some View {
        if isDirty {
            Text("Unsaved")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.orange)
        } else {
            Text("Saved")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

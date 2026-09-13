import SwiftUI

/// A lightweight, reusable markdown editor component with live preview, toolbar formatting, and split/editor/preview modes.
public struct MarkdownEditorView: View {
    @Binding var text: String
    public let title: String?
    public let isDirty: Bool
    public let onSave: (() -> Void)?

    @State private var internalMode: MarkdownEditorMode = .split
    private var externalMode: Binding<MarkdownEditorMode>?

    public init(
        text: Binding<String>,
        title: String? = nil,
        isDirty: Bool = false,
        mode: Binding<MarkdownEditorMode>? = nil,
        onSave: (() -> Void)? = nil
    ) {
        self._text = text
        self.title = title
        self.isDirty = isDirty
        self.externalMode = mode
        self.onSave = onSave
    }

    private var activeMode: Binding<MarkdownEditorMode> {
        externalMode ?? $internalMode
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Control & Formatting Bar
            headerBar

            Divider()

            // Main Editor / Preview Body
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
                            .frame(minWidth: 260)
                        previewPane
                            .frame(minWidth: 260)
                    }
                    #else
                    HStack(spacing: 0) {
                        editorPane
                        Divider()
                        previewPane
                    }
                    #endif
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Status Bar
            statusBar
        }
    }

    @ViewBuilder
    private var headerBar: some View {
        HStack(spacing: 12) {
            if let title = title {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline)

                    if isDirty {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 7, height: 7)
                            .help("Unsaved changes")
                    }
                }
            }

            // Mode Picker
            Picker("Editor Mode", selection: activeMode) {
                ForEach(MarkdownEditorMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.iconName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 240)

            if activeMode.wrappedValue != .preview {
                Divider()
                    .frame(height: 18)

                MarkdownToolbar(text: $text)
            }

            Spacer()

            if let onSave = onSave {
                Button {
                    onSave()
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!isDirty)
                .help("Save changes (Cmd+S)")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.06))
    }

    @ViewBuilder
    private var editorPane: some View {
        TextEditor(text: $text)
            .font(.system(.body, design: .monospaced))
            .padding(12)
            .scrollContentBackground(.hidden)
            .background(Color.primary.opacity(0.02))
    }

    @ViewBuilder
    private var previewPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("No content to preview.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(LocalizedStringKey(text))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
        }
        .background(Color.secondary.opacity(0.03))
    }

    @ViewBuilder
    private var statusBar: some View {
        HStack(spacing: 12) {
            let lines = text.split(separator: "\n", omittingEmptySubsequences: false).count
            let words = text.split { $0.isWhitespace || $0.isNewline }.count
            let chars = text.count

            Text("\(lines) lines • \(words) words • \(chars) chars")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

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
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.04))
    }
}

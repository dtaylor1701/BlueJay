import Foundation

/// Display modes supported by `MarkdownEditorView`.
public enum MarkdownEditorMode: String, CaseIterable, Identifiable, Sendable {
    /// Shows both the editor and live preview side-by-side (or vertically adapted on compact screens).
    case split = "Split"

    /// Displays only the raw Markdown editing pane.
    case editor = "Editor"

    /// Displays only the parsed Markdown preview pane.
    case preview = "Preview"

    /// Unique identifier conforming to `Identifiable`.
    public var id: String { rawValue }

    /// SF Symbol icon name corresponding to each display mode.
    public var iconName: String {
        switch self {
        case .split: return "rectangle.split.2x1"
        case .editor: return "pencil"
        case .preview: return "eye"
        }
    }
}

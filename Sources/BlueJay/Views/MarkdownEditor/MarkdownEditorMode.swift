import Foundation

/// Display modes supported by `MarkdownEditorView`.
public enum MarkdownEditorMode: String, CaseIterable, Identifiable, Sendable {
    case split = "Split"
    case editor = "Editor"
    case preview = "Preview"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .split: return "rectangle.split.2x1"
        case .editor: return "pencil"
        case .preview: return "eye"
        }
    }
}

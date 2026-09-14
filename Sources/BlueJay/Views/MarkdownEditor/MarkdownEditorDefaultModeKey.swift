import SwiftUI

/// An environment key defining the default display mode for `MarkdownEditorView`.
public struct MarkdownEditorDefaultModeKey: EnvironmentKey {
    /// The default mode used when no override is specified, which is `.split`.
    public static let defaultValue: MarkdownEditorMode = .split
}

public extension EnvironmentValues {
    /// The default display mode for `MarkdownEditorView` instances within this environment.
    var markdownEditorDefaultMode: MarkdownEditorMode {
        get { self[MarkdownEditorDefaultModeKey.self] }
        set { self[MarkdownEditorDefaultModeKey.self] = newValue }
    }
}

public extension View {
    /// Configures the default display mode for any `MarkdownEditorView` within this view hierarchy.
    ///
    /// - Parameter mode: The default `MarkdownEditorMode` to apply.
    /// - Returns: A view configured with the specified default markdown editor mode in its environment.
    func markdownEditorDefaultMode(_ mode: MarkdownEditorMode) -> some View {
        environment(\.markdownEditorDefaultMode, mode)
    }
}

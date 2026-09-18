#if os(macOS)
import Testing
import SwiftUI
import AppKit
@testable import BlueJay

@Suite("Markdown Editor Layout Tests")
@MainActor
struct MarkdownEditorLayoutTests {

    @MainActor
    private final class WindowHarness {
        let window: NSWindow
        let hostingView: NSHostingView<AnyView>

        init(view: some View, size: CGSize) {
            self.hostingView = NSHostingView(rootView: AnyView(view))
            self.hostingView.frame = NSRect(origin: .zero, size: size)

            self.window = NSWindow(
                contentRect: NSRect(origin: .zero, size: size),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            self.window.contentView = hostingView
            self.window.layoutIfNeeded()
            self.hostingView.layoutSubtreeIfNeeded()
        }
    }

    private func makeHarness(
        mode: MarkdownEditorMode,
        text: String = "# Header 1\n\nThis is a sample paragraph.\n\n- Bullet 1\n- Bullet 2",
        size: CGSize = CGSize(width: 600, height: 400)
    ) -> WindowHarness {
        let editor = MarkdownEditorView(
            text: .constant(text),
            mode: .constant(mode),
            onSave: {}
        )
        .frame(width: size.width, height: size.height)

        return WindowHarness(view: editor, size: size)
    }

    private func findSplitView(in v: NSView) -> NSSplitView? {
        if let split = v as? NSSplitView { return split }
        for sub in v.subviews {
            if let found = findSplitView(in: sub) { return found }
        }
        return nil
    }

    /// Tests that split mode maintains horizontal side-by-side alignment across all container widths,
    /// avoiding the defect (Perch task 69056A8A-D351-4FDB-943D-C8954D681A7E) where widths under 480 pt
    /// dropped into vertical stacking (`VSplitView` with `isVertical=false`), cutting off large editor content.
    @Test(
        "Split mode maintains horizontal alignment and avoids editor content vertical cutoff across container widths",
        arguments: [260, 320, 400, 479, 600]
    )
    func splitModeMaintainsHorizontalAlignment(width: CGFloat) throws {
        let largeContent = "# Feature Specification\n\n" + String(repeating: "Line of specification content describing requirements.\n", count: 50)
        // In TaskInspectorView, container height defaults to 320 pt (ideal height).
        // At compact widths (< 480 pt), the header bar wraps to 2 lines (~60 pt) and status bar is ~25 pt,
        // leaving ~235 pt split view height. With 12 pt top/bottom padding, the editor scroll view is 211 pt.
        // A horizontally-split editor pane should fill >= 200 pt; when vertically stacked, it squished to ~93 pt.
        let containerHeight: CGFloat = 320.0
        let expectedMinEditorHeight: CGFloat = 200.0

        let harness = makeHarness(mode: .split, text: largeContent, size: CGSize(width: width, height: containerHeight))
        let view = harness.hostingView

        let splitView = try #require(findSplitView(in: view), "NSSplitView must exist in split mode at width \(width)")
        #expect(
            splitView.isVertical,
            "Split mode at width \(width) must be horizontally aligned (side-by-side with isVertical=true), but was vertically stacked (isVertical=false), causing large editor content to be cut off."
        )

        func findEditorScrollView() -> NSScrollView? {
            guard let firstPane = splitView.subviews.first else { return nil }
            func search(in sub: NSView) -> NSScrollView? {
                if let sv = sub as? NSScrollView { return sv }
                for c in sub.subviews {
                    if let found = search(in: c) { return found }
                }
                return nil
            }
            return search(in: firstPane)
        }

        let editorScrollView = try #require(findEditorScrollView(), "Editor scroll view must be present in editor pane")
        #expect(
            editorScrollView.frame.height >= expectedMinEditorHeight,
            "Editor scroll view height (\(editorScrollView.frame.height) pt) was squished below minimum height (\(expectedMinEditorHeight) pt) at container height \(containerHeight) pt."
        )
    }


    @Test("Content portion fills available vertical space in all modes", arguments: MarkdownEditorMode.allCases)

    func contentPortionFillsSpace(mode: MarkdownEditorMode) throws {
        let containerSize = CGSize(width: 600, height: 400)
        let expectedMinContentHeight: CGFloat = 300.0

        let harness = makeHarness(mode: mode, size: containerSize)
        let view = harness.hostingView

        var contentHeight: CGFloat = 0
        func findContentScrollViews(in v: NSView) {
            if v is NSScrollView || v is NSSplitView {
                contentHeight = max(contentHeight, v.frame.height)
            }
            for sub in v.subviews {
                findContentScrollViews(in: sub)
            }
        }
        findContentScrollViews(in: view)

        try #require(contentHeight > 0, "Failed to locate content scroll view or split view in \(mode.rawValue) mode")
        #expect(
            contentHeight >= expectedMinContentHeight,
            "In \(mode.rawValue) mode, content height was \(contentHeight) pt, but expected at least \(expectedMinContentHeight) pt to fill available space."
        )

        // For split mode specifically, verify that both split items have full vertical height
        if mode == .split {
            let splitView = try #require(findSplitView(in: view), "Split view must be present in split mode")
            #expect(
                splitView.frame.height >= expectedMinContentHeight,
                "Split view height \(splitView.frame.height) pt does not fill space"
            )
            for subview in splitView.subviews where subview.frame.width > 10 {
                #expect(
                    subview.frame.height >= expectedMinContentHeight,
                    "Split subview height \(subview.frame.height) pt does not fill vertical space"
                )
            }
        }
    }

    @Test("Top control is consistent across modes without vertical label overflow or positional shifts")
    func topControlConsistencyAcrossModes() throws {
        let containerSize = CGSize(width: 600, height: 400)
        var segmentedFrames: [MarkdownEditorMode: NSRect] = [:]
        var harnesses: [WindowHarness] = []

        for mode in MarkdownEditorMode.allCases {
            let harness = makeHarness(mode: mode, size: containerSize)
            harnesses.append(harness)
            let view = harness.hostingView

            func findSegmentedControl(in v: NSView) -> NSSegmentedControl? {
                if let segmented = v as? NSSegmentedControl {
                    return segmented
                }
                // Check wrapper hosting views that may contain NSSegmentedControl
                for sub in v.subviews {
                    if let found = findSegmentedControl(in: sub) { return found }
                }
                return nil
            }

            let segmented = try #require(findSegmentedControl(in: view), "Segmented control must exist in \(mode.rawValue) mode")
            let rectInRoot = segmented.convert(segmented.bounds, to: view)
            segmentedFrames[mode] = rectInRoot
        }

        let editorRect = try #require(segmentedFrames[.editor])
        let previewRect = try #require(segmentedFrames[.preview])
        let splitRect = try #require(segmentedFrames[.split])

        // Top control Y position must be consistent across modes
        #expect(
            abs(editorRect.origin.y - previewRect.origin.y) < 2.0,
            "Top control Y position shifted between editor (\(editorRect.origin.y)) and preview (\(previewRect.origin.y))"
        )
        #expect(
            abs(editorRect.origin.y - splitRect.origin.y) < 2.0,
            "Top control Y position shifted between editor (\(editorRect.origin.y)) and split (\(splitRect.origin.y))"
        )

        // Top control X position must be consistent across modes
        #expect(
            abs(editorRect.origin.x - previewRect.origin.x) < 2.0,
            "Top control X position shifted between editor (\(editorRect.origin.x)) and preview (\(previewRect.origin.x))"
        )
        #expect(
            abs(editorRect.origin.x - splitRect.origin.x) < 2.0,
            "Top control X position shifted between editor (\(editorRect.origin.x)) and split (\(splitRect.origin.x))"
        )
    }

    @Test("MarkdownToolbar enabled state corresponds to active mode")
    func toolbarEnabledStateAcrossModes() throws {
        let containerSize = CGSize(width: 600, height: 400)

        func findToolbarButtons(in v: NSView) -> [NSButton] {
            var buttons: [NSButton] = []
            if let button = v as? NSButton, !(v is NSSegmentedControl) {
                // Exclude save button if any
                if button.title != "Save" {
                    buttons.append(button)
                }
            }
            for sub in v.subviews {
                buttons.append(contentsOf: findToolbarButtons(in: sub))
            }
            return buttons
        }

        // In Preview mode, toolbar buttons should be disabled
        let previewHarness = makeHarness(mode: .preview, size: containerSize)
        let previewButtons = findToolbarButtons(in: previewHarness.hostingView)
        for button in previewButtons {
            #expect(!button.isEnabled, "Toolbar button '\(button.title)' should be disabled in preview mode")
        }

        // In Editor mode, toolbar buttons should be enabled
        let editorHarness = makeHarness(mode: .editor, size: containerSize)
        let editorButtons = findToolbarButtons(in: editorHarness.hostingView)
        for button in editorButtons {
            #expect(button.isEnabled, "Toolbar button '\(button.title)' should be enabled in editor mode")
        }

        // In Split mode, toolbar buttons should also be enabled
        let splitHarness = makeHarness(mode: .split, size: containerSize)
        let splitButtons = findToolbarButtons(in: splitHarness.hostingView)
        for button in splitButtons {
            #expect(button.isEnabled, "Toolbar button '\(button.title)' should be enabled in split mode")
        }
    }

    @Test("Snapshot export writes valid image representation when configured")
    func snapshotExportHermetic() throws {
        let outputDir: URL
        if let envPath = ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"] {
            outputDir = URL(fileURLWithPath: envPath, isDirectory: true)
        } else {
            outputDir = FileManager.default.temporaryDirectory.appendingPathComponent("BlueJayLayoutSnapshots")
        }
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        let containerSize = CGSize(width: 600, height: 400)

        for mode in MarkdownEditorMode.allCases {
            let harness = makeHarness(mode: mode, size: containerSize)
            let view = harness.hostingView

            let bitmap = try #require(view.bitmapImageRepForCachingDisplay(in: view.bounds))
            view.cacheDisplay(in: view.bounds, to: bitmap)

            let image = NSImage(size: containerSize)
            image.addRepresentation(bitmap)

            let tiff = try #require(image.tiffRepresentation)
            let rep = try #require(NSBitmapImageRep(data: tiff))
            let png = try #require(rep.representation(using: .png, properties: [:]))

            #expect(!png.isEmpty, "Rendered snapshot PNG must not be empty for \(mode.rawValue)")
            let fileURL = outputDir.appendingPathComponent("snapshot_\(mode.rawValue).png")
            try png.write(to: fileURL)
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
        }
    }

    @Test("Markdown editor fits within various container widths without overflowing bounds", arguments: [MarkdownEditorMode.editor, MarkdownEditorMode.preview, MarkdownEditorMode.split])
    func containerBoundsCompliance(mode: MarkdownEditorMode) throws {
        let testWidths: [CGFloat] = [228, 260, 320, 479, 480, 481, 600]
        for width in testWidths {
            let containerSize = CGSize(width: width, height: 400)
            let harness = makeHarness(mode: mode, size: containerSize)
            let view = harness.hostingView

            func checkOverflow(in v: NSView) {
                let rectInRoot = v.convert(v.bounds, to: view)
                #expect(
                    rectInRoot.maxX <= width + 1.0,
                    "In \(mode.rawValue) mode at width \(width), subview \(type(of: v)) has maxX \(rectInRoot.maxX) which exceeds container width \(width)"
                )
                #expect(
                    rectInRoot.minX >= -1.0,
                    "In \(mode.rawValue) mode at width \(width), subview \(type(of: v)) has minX \(rectInRoot.minX) which spills out to the left"
                )
                #expect(
                    rectInRoot.maxY <= containerSize.height + 1.0,
                    "In \(mode.rawValue) mode at width \(width), subview \(type(of: v)) has maxY \(rectInRoot.maxY) which exceeds container height \(containerSize.height)"
                )
                #expect(
                    rectInRoot.minY >= -1.0,
                    "In \(mode.rawValue) mode at width \(width), subview \(type(of: v)) has minY \(rectInRoot.minY) which spills out vertically"
                )
                for sub in v.subviews {
                    checkOverflow(in: sub)
                }
            }

            checkOverflow(in: view)

            if mode == .split {
                if let splitView = findSplitView(in: view) {
                    #expect(splitView.isVertical, "Split view should be horizontally stacked (isVertical=true) at width \(width)")
                }
            }
        }
    }
}
#endif

# BlueJay

BlueJay is a comprehensive SwiftUI component library designed to streamline the development of modern Apple platform applications. It provides a robust set of reusable UI components, view modifiers, and data flow utilities that simplify common tasks such as file handling, authentication, and data presentation.

## Features

BlueJay is organized into several logical component groups to help you build consistent and interactive user interfaces:

### 📂 File Handling
Specialized views for managing files with support for bookmarks, thumbnails, and drag-and-drop:
*   `FileView`: A platform-native file selection and display component.
*   `FileDataView`: For displaying detailed information about a specific file.
*   `DragDropView`: A cross-platform component and view modifier for handling file drop interactions.
*   `FileThumbnailView`: Asynchronous thumbnail generation and display for various file types.

### 🖼️ Core UI Components
Commonly used interface elements styled for consistency:
*   `AuthenticationView`: A ready-to-use layout for login and signup flows.
*   `URLField`: A specialized text field for URL input and validation.
*   `FaviconView`: Automatically fetches and displays favicons for web URLs.
*   `DeleteButton`: A standardized destructive action button.
*   `EditView`: A container for record editing interfaces.

### 🏗️ Layout & Containers
View modifiers and containers that ensure consistent presentation across your app:
*   `ProgressContainer`: Handles loading and progress states gracefully.
*   `SheetContainer`: Standardizes the appearance and behavior of modal sheets.
*   `ListButtonContentContainer`: Optimizes button layouts within list rows.

### 🔄 Data Flow
Utilities to manage application state and common data patterns:
*   `ProgressState`: A standardized way to track and react to asynchronous task progression.
*   `Identifiable+Extensions`: Helpers for working with identifiable data collections.

## Installation

### Swift Package Manager

Add BlueJay to your project via Swift Package Manager. In Xcode, go to `File > Add Packages...` and enter the repository URL:

```text
https://github.com/[your-username]/BlueJay.git
```

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/[your-username]/BlueJay.git", from: "1.0.0")
]
```

## Dependencies

BlueJay leverages the following libraries to provide its functionality:
*   [Goose](https://github.com/dtaylor1701/Goose.git): Used for core data models and file system abstractions.

## Requirements

*   **iOS** 16.0+
*   **macOS** 13.0+
*   **tvOS** 16.0+
*   **watchOS** 7.0+
*   **Swift** 5.9+

## Usage

### Simple File Selection
```swift
import BlueJay
import SwiftUI

struct MyView: View {
    @State private var selectedFile: File?

    var body: some View {
        FileView(
            title: "Document",
            file: $selectedFile,
            allowedContentTypes: [.pdf, .text]
        )
    }
}
```

### Displaying a Favicon
```swift
import BlueJay
import SwiftUI

struct BookmarkView: View {
    var body: some View {
        FaviconView(url: URL(string: "https://apple.com"))
            .frame(width: 32, height: 32)
    }
}
```

## Examples

The repository includes a `BlueJay Examples` project in the `Examples/` directory. This project demonstrates how to implement and customize various components provided by the library.

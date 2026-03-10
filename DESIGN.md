# BlueJay Design Document

## 1. High-Level Architecture & Technical Stack

BlueJay is a cross-platform SwiftUI component library designed to provide a cohesive and reusable set of UI elements and data flow utilities for Apple ecosystem applications. It bridges the gap between raw data models and user interface requirements, specifically focusing on file management, authentication workflows, and modern state representation.

### Technical Stack
- **Language**: Swift 5.9+
- **Framework**: SwiftUI (Primary UI framework)
- **Platforms**: iOS 16.0+, macOS 13.0+, tvOS 16.0+, watchOS 7.0+
- **Dependency Management**: Swift Package Manager (SPM)
- **Core Dependency**: [Goose](https://github.com/dtaylor1701/Goose.git) (Model abstractions and utilities)

## 2. Design Philosophies & Principles

- **Declarative Composition**: Leveraging SwiftUI’s declarative nature to build complex interfaces from small, focused components.
- **Protocol-Oriented**: Using Swift protocols (e.g., `Identifiable`) to ensure flexibility and type safety across different data types.
- **Platform Idiomaticity**: While cross-platform, components respect platform-specific behaviors (e.g., using `NSWorkspace` on macOS for file interaction).
- **Error Transparency**: Providing clear state representation for asynchronous operations via `ProgressState`.
- **Surgical Dependencies**: Minimizing external footprints, relying primarily on first-party frameworks and the lightweight `Goose` library.

## 3. Technical Environment & Tooling

### Setup & Build System
The project is structured as a Swift Package, allowing for easy integration into larger projects.
- **Package.swift**: Defines targets, products, and dependencies.
- **Xcode Workspace**: `BlueJay-Workspace.xcworkspace` provides an integrated environment for developing the library alongside example applications.

### Dependency Management
BlueJay uses SPM for all external logic. It currently integrates the `Goose` package to handle specialized model logic, such as file URL resolution and bookmarking.

## 4. Data Models & State Management

### State Representation
The core of BlueJay's state management is the `ProgressState` enum, which tracks the lifecycle of asynchronous operations:
```swift
public enum ProgressState<Value, Error: Swift.Error> {
  case started
  case finished(Result<Value, Error>)
}
```

### File Handling
BlueJay interacts with file system entities through a `File` abstraction (provided by Goose). Key mechanisms include:
- **Security Scoped Bookmarks**: Persisting file access across application launches.
- **UTType Filtering**: Restricting file selection to specific uniform type identifiers.

## 5. Key Components & Interactions

### UI Components
- **File System Views**:
    - `FileView`: A high-level picker and viewer for individual files.
    - `FileDropArea`: A container for drag-and-drop file interactions.
    - `FileThumbnailView`: Visual representation of file contents or icons.
- **Generic Inputs & Buttons**:
    - `URLField`: Specialized text input for validated URLs.
    - `AuthenticationView`: Standardized UI for login/signup flows.
    - `DeleteButton`: A consistent destructive action button.
- **Utilities**:
    - `FaviconView`: Asynchronous loading and display of website icons.
    - `ProgressContainer`: A wrapper for displaying activity indicators based on `ProgressState`.

### Internal Interactions
Components often use `ViewModifiers` like `SheetContainer` and `ListButtonContentContainer` to maintain consistent layout and presentation logic across the library.

## 6. Technical Specifications

### Error Handling
Errors are propagated through the `Result` type within `ProgressState`. The library includes a dedicated `Logger` for internal diagnostics and developer feedback.

### Concurrency Model
BlueJay utilizes Swift's structured concurrency (`async/await` and `.task` modifiers) for background operations like favicon fetching and file bookmark resolution.

### Performance Considerations
- **Thumbnail Caching**: Efficient rendering of file previews.
- **Lazy Loading**: Favicons and heavy UI elements are loaded on-demand to minimize initial view rendering time.

## 7. Testing Infrastructure

### Strategy
The project employs a dual-layered testing strategy:
- **Unit Testing**: Located in `Tests/BlueJayTests`, focusing on logic within `DataFlow` and `Extensions`.
- **UI & Integration Testing**: Validated through the `Examples/BlueJay Examples` application, ensuring components behave correctly across different Apple platforms and screen sizes.

## 8. Security & Scalability

### Security
- **Sandbox Compliance**: Strictly adheres to Apple’s App Sandbox requirements, using security-scoped bookmarks for file access.
- **Credential Safety**: `AuthenticationView` is designed to be a UI wrapper, ensuring sensitive data handling is deferred to the consuming application's secure storage (e.g., Keychain).

### Scalability
The modular design allows developers to import only the necessary parts of the library. As a Swift Package, it scales with the host application's architecture, whether it be MVVM, TCA, or a standard SwiftUI data flow.

import SwiftUI
import BlueJay

enum Example: String, CaseIterable, Identifiable {
  case authenticationView
  case deleteButton
  case editView
  case faviconView
  case fileViews
  case listButtonContent
  case progressContainer
  case sheetContainer
  case urlField
  
  var id: String { rawValue }
  
  var title: String {
    switch self {
    case .authenticationView: "Authentication View"
    case .deleteButton: "Delete Button"
    case .editView: "Edit View"
    case .faviconView: "Favicon View"
    case .fileViews: "File Views (macOS)"
    case .listButtonContent: "List Button Content"
    case .progressContainer: "Progress Container"
    case .sheetContainer: "Sheet Container"
    case .urlField: "URL Field"
    }
  }

  @ViewBuilder
  func view() -> some View {
    switch self {
    case .authenticationView:
      AuthenticationExample()
    case .deleteButton:
      DeleteButtonExample()
    case .editView:
      EditViewExample()
    case .faviconView:
      FaviconExample()
    case .fileViews:
      #if os(macOS)
      FileViewsExample()
      #else
      Text("File Views are macOS only")
      #endif
    case .listButtonContent:
      ListButtonContentExample()
    case .progressContainer:
      ProgressContainerExample()
    case .sheetContainer:
      SheetContainerExample()
    case .urlField:
      URLFieldExample()
    }
  }
}

// MARK: - Example Views

struct AuthenticationExample: View {
  var body: some View {
    AuthenticationView(
      onLogin: { creds in
        print("Login with \(creds.email)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
      },
      onRegister: { creds in
        print("Register with \(creds.email)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
      },
      heroContent: {
        VStack {
          Image(systemName: "bird.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .padding()
          Text("BlueJay")
            .font(.largeTitle)
            .bold()
        }
      }
    )
  }
}

struct DeleteButtonExample: View {
  struct Item: Identifiable {
    let id = UUID()
    let name: String
  }
  @State var items = [Item(name: "Item 1"), Item(name: "Item 2"), Item(name: "Item 3")]

  var body: some View {
    List(items) { item in
      HStack {
        Text(item.name)
        Spacer()
        DeleteButton(item: item, array: $items)
      }
    }
  }
}

struct EditViewExample: View {
  @State var isPresented = false
  @State var text = "Edit me"

  var body: some View {
    VStack {
      Text(text)
      Button("Edit") { isPresented = true }
    }
    .sheet(isPresented: $isPresented) {
      EditView(content: {
        TextField("Text", text: $text)
          .padding()
      }, onDone: {
        print("Done editing")
      })
    }
  }
}

struct FaviconExample: View {
  var body: some View {
    List {
      HStack {
        FaviconView(url: URL(string: "https://apple.com"))
          .frame(width: 32, height: 32)
        Text("Apple")
      }
      HStack {
        FaviconView(url: URL(string: "https://google.com"))
          .frame(width: 32, height: 32)
        Text("Google")
      }
      HStack {
        FaviconView(url: URL(string: "https://github.com"))
          .frame(width: 32, height: 32)
        Text("GitHub")
      }
    }
  }
}

#if os(macOS)
import Goose
struct FileViewsExample: View {
  @State var file: File?
  var body: some View {
    VStack(spacing: 20) {
      FileView(title: "Document", file: $file, allowedContentTypes: [.item])
      
      if let file {
        FileThumbnailView(file: file)
          .frame(width: 100, height: 100)
        
        FileDataView(file: .constant(file)) { data in
          Text("File size: \(data.count) bytes")
        }
      }
      
      Text("Drop a file here")
        .frame(width: 200, height: 100)
        .background(Color.gray.opacity(0.2))
        .fileDropArea { droppedFile in
          self.file = droppedFile
        }
    }
    .padding()
  }
}
#endif

struct ListButtonContentExample: View {
  @State var selection: Int?
  var body: some View {
    List {
      ForEach(0..<5) { index in
        Button {
          selection = index
        } label: {
          Text("Item \(index)")
            .asListButtonContent(isSelected: selection == index)
        }
        .buttonStyle(.plain)
      }
    }
  }
}

struct ProgressContainerExample: View {
  @State var state: ProgressState<String, Error> = .started
  var body: some View {
    VStack {
      ProgressContainer(progressState: state) { value in
        Text("Loaded: \(value)")
      } errorContent: { error in
        Text("Error: \(error.localizedDescription)")
      }
      
      HStack {
        Button("Start") { state = .started }
        Button("Succeed") { state = .finished(.success("Success!")) }
        Button("Fail") { state = .finished(.failure(NSError(domain: "test", code: 0))) }
      }
      .padding()
    }
  }
}

struct SheetContainerExample: View {
  @State var isPresented = false
  var body: some View {
    Button("Show Sheet") { isPresented = true }
    .sheet(isPresented: $isPresented) {
      Text("Content of the sheet")
        .asSheet(configuration: .cancelDone(onDone: {
          print("Done pressed")
        }))
    }
  }
}

struct URLFieldExample: View {
  @State var url: URL? = URL(string: "https://ramblelogic.com")
  var body: some View {
    Form {
      URLField("Website", url: $url)
      if let url {
        Text("Actual URL: \(url.absoluteString)")
      }
    }
    .padding()
  }
}

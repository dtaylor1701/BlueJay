import SwiftUI

struct ContentView: View {
    @State private var selectedExample: Example?

    var body: some View {
        NavigationSplitView {
            List(Example.allCases, selection: $selectedExample) { example in
                NavigationLink(value: example) {
                    Text(example.title)
                }
            }
            .navigationTitle("BlueJay Examples")
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        } detail: {
            if let example = selectedExample {
                example.view()
                    .navigationTitle(example.title)
            } else {
                Text("Select an example")
            }
        }
    }
}

#Preview {
    ContentView()
}

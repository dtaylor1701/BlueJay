import SwiftUI

public struct PromptButton: View {
    public let title: String
    public let systemImage: String
    public let completion: (String) async throws -> Void
    
    @State private var isShowingSheet = false
    @State private var promptText = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    public init(
        title: String = "Generate",
        systemImage: String = "sparkles",
        completion: @escaping (String) async throws -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.completion = completion
    }
    
    public var body: some View {
        Button {
            isShowingSheet = true
        } label: {
            let label = Label(title, systemImage: systemImage)
            if #available(iOS 17.0, macOS 14.0, *) {
                label.symbolEffect(.bounce, value: isShowingSheet)
            } else {
                label
            }
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .sheet(isPresented: $isShowingSheet) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("AI Content Generation")
                        .font(.headline)
                    
                    Text("Provide a prompt or context to guide the generation.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextEditor(text: $promptText)
                        .frame(minHeight: 120)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                        .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Button("Cancel", role: .cancel) {
                            isShowingSheet = false
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            Task {
                                await generate()
                            }
                        } label: {
                            if isGenerating {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text("Submit")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(promptText.isEmpty || isGenerating)
                    }
                    .padding(.bottom)
                    
                    Spacer()
                }
                .padding(.top)
                .frame(minWidth: 400, minHeight: 300)
            }
            .presentationDetents([.medium])
        }
    }
    
    @MainActor
    private func generate() async {
        isGenerating = true
        errorMessage = nil
        
        do {
            try await completion(promptText)
            isShowingSheet = false
            promptText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
}

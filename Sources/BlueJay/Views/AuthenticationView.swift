import SwiftUI

/// A standard authentication view providing login and registration forms.
///
/// `AuthenticationView` handles the UI and state for email/password authentication,
/// including switching between login and registration modes.
public struct AuthenticationView<Content: View>: View {
  // MARK: - Types

  /// The available authentication modes.
  public enum Configuration {
    case login
    case register
  }

  /// The credentials collected from the form.
  public struct Credentials {
    public let email: String
    public let password: String
  }

  // MARK: - Configuration

  let onLogin: (Credentials) async throws -> Void
  let onRegister: (Credentials) async throws -> Void
  let content: () -> Content

  // MARK: - View State

  @State var configuration: Configuration
  @State private var email: String
  @State private var password: String
  @State private var submitting: Bool = false
  @State private var error: Error?

  private var submitCopy: String {
    switch configuration {
    case .login: "Login"
    case .register: "Register"
    }
  }

  private var switchCopy: String {
    switch configuration {
    case .login: "Don't have an account? Register"
    case .register: "Already have an account? Login"
    }
  }

  // MARK: - Initializers

  /// - Parameters:
  ///   - email: Initial email value.
  ///   - password: Initial password value.
  ///   - initialConfiguration: Whether to start in login or register mode.
  ///   - onLogin: Async closure called when the user submits the login form.
  ///   - onRegister: Async closure called when the user submits the registration form.
  ///   - heroContent: A view builder for content displayed at the top of the form (e.g., a logo).
  public init(
    email: String = "",
    password: String = "",
    initialConfiguration: Configuration = .register,
    onLogin: @escaping (Credentials) async throws -> Void,
    onRegister: @escaping (Credentials) async throws -> Void,
    heroContent: @escaping () -> Content
  ) {
    self.email = email
    self.password = password
    configuration = initialConfiguration
    self.onLogin = onLogin
    self.onRegister = onRegister
    self.content = heroContent
  }

  // MARK: - Content

  public var body: some View {
    VStack {
      content()
      Spacer()
      errorDescription
      form
    }
  }

  @ViewBuilder
  private var submitFooter: some View {
    Button(switchCopy) {
      configuration = configuration == .login ? .register : .login
    }
  }

  @ViewBuilder
  private var overlay: some View {
    if submitting {
      ProgressView()
    }
  }

  @ViewBuilder
  private var form: some View {
    VStack(spacing: 16) {
      Section {
        TextField("Email", text: $email)
          #if os(iOS) || os(tvOS) || os(watchOS)
            .textInputAutocapitalization(.never)
          #endif
          .disableAutocorrection(true)

        SecureField("Password", text: $password)
      }
      .textFieldStyle(.roundedBorder)

      Section(footer: submitFooter) {
        Button {
          Task {
            submitting = true
            do {
              try await submit()
            } catch {
              self.error = error
            }
            submitting = false
          }
        } label: {
          HStack {
            Spacer()
            Text(submitCopy)
              .padding(.vertical, 4)
            Spacer()
          }
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding(16)
    .background {
      Color.white
    }
    .cornerRadius(20)
    .padding(20)
    .disabled(submitting)
    .overlay(overlay)
  }

  @ViewBuilder
  private var errorDescription: some View {
    if error != nil {
      Text("Something went wrong. Please try again.")
        .foregroundStyle(Color.red)
    }
  }

  // MARK: - Utilities

  private func submit() async throws {
    switch configuration {
    case .login:
      try await onLogin(Credentials(email: email, password: password))
    case .register:
      try await onRegister(Credentials(email: email, password: password))
    }
  }
}

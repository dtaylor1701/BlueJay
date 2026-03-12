import SwiftUI

/// A reusable section for forms that includes a title and a text field.
public struct FormSection: View {
  private let title: String
  private let placeholder: String
  private let secure: Bool
  private let textFieldWidth: CGFloat

  @Binding
  private var value: String

  /// - Parameters:
  ///   - title: The header title for the section.
  ///   - placeholder: The placeholder text for the text field.
  ///   - value: A binding to the text field's value.
  ///   - secure: Whether to use a `SecureField` for password input.
  ///   - textFieldWidth: The width of the text field.
  public init(
    _ title: String,
    placeholder: String,
    value: Binding<String>,
    secure: Bool = false,
    textFieldWidth: CGFloat = 200
  ) {
    self.title = title
    self.placeholder = placeholder
    self._value = value
    self.secure = secure
    self.textFieldWidth = textFieldWidth
  }

  public var body: some View {
    Section {
      if secure {
        SecureField(placeholder, text: $value)
          .textFieldStyle(.roundedBorder)
          .frame(width: textFieldWidth)
          .padding(4)
      } else {
        TextField(placeholder, text: $value)
          .textFieldStyle(.roundedBorder)
          .frame(width: textFieldWidth)
          .padding(4)
      }
    } header: {
      Text(title)
    }
  }
}

#Preview {
  Form {
    FormSection("Username", placeholder: "Enter username", value: .constant(""))
    FormSection("Password", placeholder: "Enter password", value: .constant(""), secure: true)
  }
}

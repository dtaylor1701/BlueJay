import SwiftUI

enum Example: String, CaseIterable, Identifiable {
  case deleteButton
  case editView
  case fileDataView
  case fileView
  case progressContainer
  
  var id: String { rawValue }
  
  var title: String {
    switch self {
    case .deleteButton:
      "Delete Button"
    case .editView:
      "Edit View"
    case .fileDataView:
      "File Data View"
    case .fileView:
      "File View"
    case .progressContainer:
      "Progress Container"
    }
  }
}

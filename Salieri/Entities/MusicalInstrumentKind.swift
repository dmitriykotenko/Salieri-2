// @ Dmitry Kotenko

import Foundation
import UIKit


enum MusicalInstrumentKind: Equatable, Hashable, Codable, CaseIterable {

  case guitar
  case drum
  case wind

  var icon: UIImage {
    switch self {
    case .guitar:
      return .guitarIcon
    case .drum:
      return .drumIcon
    case .wind:
      return .windIcon
    }
  }

  var title: String {
    switch self {
    case .guitar:
      return "гитара"
    case .drum:
      return "ударные"
    case .wind:
      return "духовые"
    }
  }
}

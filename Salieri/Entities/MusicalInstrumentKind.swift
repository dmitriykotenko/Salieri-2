// @ Dmitry Kotenko

import Foundation
import UIKit


enum MusicalInstrumentKind: Equatable, Hashable, Codable, CaseIterable {

  case guitar
  case drum
  case wind
  case mic

  var icon: UIImage {
    switch self {
    case .guitar:
      return .guitarIcon
    case .drum:
      return .drumIcon
    case .wind:
      return .windIcon
    case .mic:
      return .micIcon
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
    case .mic:
      return "микрофон"
    }
  }

  var predefinedSamples: [AudioSample] {
    switch self {
    case .guitar:
      return AudioSample.guitarSamples
    case .drum:
      return AudioSample.drumSamples
    case .wind:
      return AudioSample.windSamples
    case .mic:
      return []
    }
  }
}

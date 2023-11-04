// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension Sequence {

  func asyncMap<OtherElement>(_ transform: (Element) async -> OtherElement) async -> [OtherElement] {
    var result: [OtherElement] = []

    for element in self {
      await result.append(transform(element))
    }

    return result
  }
}

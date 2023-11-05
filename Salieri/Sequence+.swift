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


extension Array {

  func chunks(length: Int) -> [[Element]] {
    stride(from: 0, to: count, by: length)
      .map { Array(dropFirst($0).prefix(length)) }
  }

  func chunksFromRight(length: Int) -> [[Element]] {
    stride(from: 0, to: count, by: length)
      .map { Array(dropLast($0).suffix(length)) }
      .reversed()
  }
}

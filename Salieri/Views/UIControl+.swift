// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


class Control: UIControl {

  var isTransparentForGestures: Bool
  var customAlignmentRectInsets: UIEdgeInsets

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(isTransparentForGestures: Bool = false,
       alignmentRectInsets: UIEdgeInsets = .zero) {
    self.isTransparentForGestures = isTransparentForGestures
    self.customAlignmentRectInsets = alignmentRectInsets

    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
  }

  override var alignmentRectInsets: UIEdgeInsets {
    customAlignmentRectInsets
  }

  override open func hitTest(_ point: CGPoint,
                             with event: UIEvent?) -> UIView? {
    let hit = super.hitTest(point, with: event)

    switch hit {
    case self: return isTransparentForGestures ? nil : self
    default: return hit
    }
  }
}

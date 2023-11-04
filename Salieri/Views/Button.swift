// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit


class Button: UIButton {

  override var isEnabled: Bool {
    didSet { alpha = isEnabled ? 1 : 0.5 }
  }
}

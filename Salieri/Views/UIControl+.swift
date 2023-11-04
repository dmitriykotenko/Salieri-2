// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


class Control: UIControl {

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
  }
}

// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension UIView {

  func preparedForAutoLayout() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
}


class View: UIView {

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
  }
}

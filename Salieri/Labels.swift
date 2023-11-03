// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension UILabel {

  static var standard: UILabel {
    label(font: .systemFont(ofSize: 24))
  }

  static func label(font: UIFont,
                    textColor: UIColor = .black,
                    textAlignment: NSTextAlignment = .left,
                    isMultilined: Bool = true) -> UILabel {
    let label = UILabel()

    label.translatesAutoresizingMaskIntoConstraints = false

    label.font = font
    label.textColor = textColor
    label.textAlignment = textAlignment

    if isMultilined {
      label.numberOfLines = 0
      label.lineBreakMode = .byWordWrapping
    } else {
      label.numberOfLines = 1
      label.lineBreakMode = .byTruncatingTail
    }

    return label
  }

  func with(text: String?) -> Self {
    self.text = text
    return self
  }

  func with(textColor: UIColor) -> Self {
    self.textColor = textColor
    return self
  }
}

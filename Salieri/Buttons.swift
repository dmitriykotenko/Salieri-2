// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension UIButton {

  static var standard: UIButton {
    button(
      font: .systemFont(ofSize: 24),
      cornerRadius: 8
    )
  }

  static func button(font: UIFont,
                     textColor: UIColor = .white,
                     backgroundColor: UIColor = .systemBlue,
                     cornerRadius: CGFloat = 0,
                     height: CGFloat? = 44) -> UIButton {
    let button = UIButton()

    button.translatesAutoresizingMaskIntoConstraints = false

    if let height {
      button.snp.makeConstraints { $0.height.equalTo(height) }
    }

    button.titleLabel?.font = font
    button.setTitleColor(textColor, for: UIControl.State.normal)

    button.backgroundColor = backgroundColor
    button.layer.cornerRadius = cornerRadius

    return button
  }

  func with(title: String) -> Self {
    setTitle(title, for: UIControl.State.normal)
    return self
  }
}

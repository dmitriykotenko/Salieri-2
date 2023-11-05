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

  static func small(height: CGFloat = 44) -> UIButton {
    button(
      font: .systemFont(ofSize: 14),
      cornerRadius: 0,
      height: height
    )
  }

  static func button(font: UIFont,
                     textColor: UIColor = .white,
                     backgroundColor: UIColor = .systemBlue,
                     cornerRadius: CGFloat = 0,
                     height: CGFloat? = 44) -> UIButton {
    let button = Button()

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

  func with(titleColor: UIColor,
            forState state: UIControl.State) -> Self {
    setTitleColor(titleColor, for: state)
    return self
  }

  func with(selectedTitleColor: UIColor) -> Self {
    with(titleColor: selectedTitleColor, forState: .selected)
  }

  func with(backgroundColor: UIColor) -> Self {
    self.backgroundColor = backgroundColor
    return self
  }
}

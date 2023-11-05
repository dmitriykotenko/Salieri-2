// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension UIImageView {

  static func imageView(image: UIImage,
                        backgrondColor: UIColor? = nil,
                        borderColor: UIColor? = nil,
                        borderWidth: CGFloat = 0,
                        cornerRadius: CGFloat = 0,
                        size: CGSize?) -> UIImageView {
    let imageView = UIImageView().preparedForAutoLayout()

    imageView.backgroundColor = backgrondColor

    imageView.layer.borderColor = borderColor?.cgColor
    imageView.layer.borderWidth = borderWidth
    imageView.layer.cornerRadius = cornerRadius

    if let size {
      imageView.contentMode = .scaleAspectFit
      imageView.snp.makeConstraints {
        $0.size.equalTo(size)
      }
    } else {
      imageView.contentMode = .center
      imageView.setContentHuggingPriority(.required, for: .horizontal)
      imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
      imageView.setContentHuggingPriority(.required, for: .vertical)
      imageView.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    imageView.image = image

    return imageView
  }

  func with(image: UIImage) -> Self {
    self.image = image
    return self
  }

  func with(backgrondColor: UIColor) -> Self {
    self.backgroundColor = backgrondColor
    return self
  }
}

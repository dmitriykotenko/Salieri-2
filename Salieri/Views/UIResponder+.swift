// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension UIResponder {

  var containingViewController: UIViewController? {
    (next as? UIViewController) ?? next?.containingViewController
  }
}

// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension NumberFormatter {

  static var float: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = .init(identifier: "ru_RU")
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
  }
}

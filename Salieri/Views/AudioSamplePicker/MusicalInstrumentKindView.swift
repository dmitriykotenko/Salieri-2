// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class MusicalInstrumentKindView: View {

  var instrumentKind: MusicalInstrumentKind {
    didSet {
      imageView.image = instrumentKind.icon.withTintColor(tintColor)
      titleLabel.text = instrumentKind.title
    }
  }

  private(set) lazy var imageView = UIImageView.imageView(
    image: instrumentKind.icon.withTintColor(tintColor),
    size: .init(width: 80, height: 64)
  )

  private(set) lazy var titleLabel = UILabel.small
    .with(textColor: tintColor)
    .with(text: instrumentKind.title)

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(instrumentKind: MusicalInstrumentKind) {
    self.instrumentKind = instrumentKind

    super.init()

    self.tintColor = .systemTeal

    setupLayout()
  }

  private func setupLayout() {
    snp.makeConstraints { $0.width.height.equalTo(120) }

    addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().offset(16)
    }

    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-16)
//      $0.top.equalTo(imageView.snp.bottom).offset(4)
    }
  }
}

// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AddAudioChannelView: View {

  var channelAdded = PublishSubject<AudioChannel>()
  var micTapped = PublishSubject<Void>()

  private let titleLabel = UILabel.small
    .with(textColor: .systemTeal)
    .with(text: " Добавить инструмент ")

  private let buttonsContainer = View(
    isTransparentForGestures: true,
    alignmentRectInsets: .init(top: 200, left: 0, bottom: 0, right: 0)
  )

  private lazy var instrumentButtons = MusicalInstrumentKind.allCases.map {
    AudioSamplePickerView(
      instrumentKind: $0,
      samples: $0.predefinedSamples
    )
  }

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init() {
    super.init(
      isTransparentForGestures: true,
      alignmentRectInsets: .init(top: 200, left: 0, bottom: 0, right: 0)
    )

    setupLayout()

    instrumentButtons.forEach {
      $0.audioSamplePicked
        .subscribe(onNext: { [weak self] in
          self?.addChannel(sample: $0)
        })
        .disposed(by: disposeBag)

      $0.micTapped
        .subscribe(onNext: { [weak self] in
          self?.micTapped.onNext(())
        })
        .disposed(by: disposeBag)
    }
  }

  private func setupLayout() {
    clipsToBounds = false

    let border = View()
    border.layer.cornerRadius = 8
    border.layer.borderWidth = 2
    border.layer.borderColor = UIColor.systemTeal.cgColor

    addSubview(border)
    border.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }

    addSubview(buttonsContainer)
    buttonsContainer.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }

    buttonsContainer.addHorizontalStack(ofChildViews: instrumentButtons)

    insertSubview(titleLabel, belowSubview: buttonsContainer)
    titleLabel.backgroundColor = .mainBackground
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(6)
      $0.leading.equalToSuperview().offset(32)
    }
  }

  private func addChannel(sample: AudioSample) {
    channelAdded.onNext(.init(segment: .init(sample: sample)))
  }

  private func addButton(_ button: UIButton,
                         previousButton: UIButton?,
                         isLast: Bool) {
    buttonsContainer.addSubview(button)
    button.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(16)
      if let previousButton {
        $0.leading.equalTo(previousButton.snp.trailing).offset(16)
      } else {
        $0.leading.equalToSuperview().offset(16)
      }

      if isLast {
        $0.trailing.equalToSuperview().offset(-16)
      }
    }
  }

  private func onTap(of button: UIButton,
                     tapHandler: @escaping (AddAudioChannelView) -> Void) {
    button.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self.map(tapHandler)
      })
      .disposed(by: disposeBag)
  }

  func onGlobalTouch(at point: CGPoint) {
    instrumentButtons.forEach { $0.onGlobalTouch(at: point) }
  }
}

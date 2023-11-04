// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AddAudioChannelView: View {

  var channelAdded = PublishSubject<AudioChannel>()

  private let titleLabel = UILabel.small
    .with(textColor: .systemTeal)
    .with(text: " Добавить инструмент ")

  private let buttonsContainer = View()

  private let samples: [AudioSample] = [
    .cMinBass,
    .eMinSwellingPad,
    .d80811
  ]

  private lazy var sampleButtons = samples.map {
    UIButton.small
      .with(title: $0.name)
      .with(selectedTitleColor: .red)
      .with(titleColor: .yellow, forState: .highlighted)
  }

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override init() {
    super.init()

    setupLayout()

    zip(samples, sampleButtons).forEach { sample, button in
      onTap(
        of: button,
        tapHandler: {
          $0.addChannel(sample: sample)
        }
      )
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

    sampleButtons.enumerated().forEach { index, button in
      addButton(
        button,
        previousButton: index > 0 ? sampleButtons[index - 1] : nil,
        isLast: index == sampleButtons.count - 1
      )
    }

    addSubview(titleLabel)
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
}

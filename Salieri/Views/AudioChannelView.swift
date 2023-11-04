// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AudioChannelView: View {

  var channel = BehaviorSubject<AudioChannel?>(value: nil)

  let titleLabel = UILabel.small

  let buttonsContainer = View()
  let slidersContainer = View()

  let firstSampleButton = UIButton.small
    .with(title: "Сэмпл №1")
    .with(selectedTitleColor: .red)

  let secondSampleButton = UIButton.small
    .with(title: "Сэмпл №2")
    .with(selectedTitleColor: .red)

  let pauseButton = UIButton.small
    .with(title: "Пауза")
    .with(selectedTitleColor: .red)

  let muteButton = UIButton.small
    .with(title: "Заглушить")
    .with(selectedTitleColor: .red)

  let loudnessSlider = SliderView(title: "Громкость", bounds: 0...5)
  let silenceLengthSlider = SliderView(title: "Скорость", bounds: 0...5)

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override init() {
    super.init()

    setupLayout()

    channel
      .subscribe(onNext: { [weak self] _ in self?.channelUpdated() })
      .disposed(by: disposeBag)

    onTap(of: firstSampleButton) { $0.firstSampleButtonTapped() }
    onTap(of: secondSampleButton) { $0.secondSampleButtonTapped() }
    onTap(of: pauseButton) { $0.pauseButtonTapped() }
    onTap(of: muteButton) { $0.muteButtonTapped() }

    setupSliders()
  }

  private func setupLayout() {
    backgroundColor = .systemOrange.withAlphaComponent(0.5)

    addSubview(buttonsContainer)
    buttonsContainer.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    setupButtonsLayout()

    addSubview(slidersContainer)
    slidersContainer.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
      $0.top.equalTo(buttonsContainer.snp.bottom)
    }

    setupSlidersLayout()
  }

  private func setupButtonsLayout() {
    buttonsContainer.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalToSuperview()
    }

    buttonsContainer.addSubview(firstSampleButton)
    firstSampleButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
    }

    buttonsContainer.addSubview(secondSampleButton)
    secondSampleButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(firstSampleButton.snp.trailing).offset(16)
    }

    buttonsContainer.addSubview(pauseButton)
    pauseButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(secondSampleButton.snp.trailing).offset(16)
    }

    buttonsContainer.addSubview(muteButton)
    muteButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(pauseButton.snp.trailing).offset(16)
      $0.trailing.equalToSuperview()
    }
  }

  private func setupSlidersLayout() {
    slidersContainer.addSubview(silenceLengthSlider)
    silenceLengthSlider.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.leading.trailing.equalToSuperview()
    }

    slidersContainer.addSubview(loudnessSlider)
    loudnessSlider.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
      $0.top.equalTo(silenceLengthSlider.snp.bottom).offset(8)
    }
  }

  private func setupSliders() {
    silenceLengthSlider.value
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] newSilenceLength in
        self?.modifyChannel {
          $0.with(\.segment.silenceLength, CGFloat(newSilenceLength))
        }
      })
      .disposed(by: disposeBag)

    loudnessSlider.value
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] newLoudness in
        self?.modifyChannel {
          $0.with(\.segment.loudness, Int(newLoudness * 100))
        }
      })
      .disposed(by: disposeBag)
  }

  private func channelUpdated() {
    guard let channel = try? self.channel.value() else { return }

    let silenceLengthFormatter = NumberFormatter()
    silenceLengthFormatter.maximumFractionDigits = 2

    titleLabel.text = silenceLengthFormatter.string(
      from: channel.segment.silenceLength as NSNumber
    )

    firstSampleButton.isSelected =
      (channel.segment.sample.name == AudioSample.cMinBass.name)

    secondSampleButton.isSelected =
      (channel.segment.sample.name == AudioSample.eMinSwellingPad.name)

    pauseButton.isSelected = channel.isPaused
    muteButton.isSelected = channel.isMuted
  }

  private func onTap(of button: UIButton,
                     tapHandler: @escaping (AudioChannelView) -> Void) {
    button.rx.tap
      .subscribe(onNext: { [weak self] _ in self.map(tapHandler) })
      .disposed(by: disposeBag)
  }

  private func firstSampleButtonTapped() {
    guard !firstSampleButton.isSelected else { return }

    modifyChannel {
      $0.with(\.segment.sample, .cMinBass)
    }
  }

  private func secondSampleButtonTapped() {
    guard !secondSampleButton.isSelected else { return }

    modifyChannel {
      $0.with(\.segment.sample, .eMinSwellingPad)
    }
  }

  private func pauseButtonTapped() {
    modifyChannel { $0.with(\.isPaused, { !$0 }) }
  }

  private func muteButtonTapped() {
    modifyChannel { $0.with(\.isMuted, { !$0 }) }
  }

  private func modifyChannel(_ transform: (AudioChannel) -> AudioChannel) {
    self.channel.onNext(
      (try? self.channel.value()).map(transform)
    )
  }

  func with(channel: AudioChannel) -> Self {
    self.channel.onNext(channel)
    return self
  }
}

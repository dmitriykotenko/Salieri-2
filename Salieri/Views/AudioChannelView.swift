// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AudioChannelView: View {

  var channelEvent = PublishSubject<AudioChannelEvent>()

  private(set) var channel: AudioChannel

  private(set) lazy var deleteChannel =
    deleteButton.rx.tap.compactMap { [weak self] in self?.channel }

  let buttonsContainer = View()
  let slidersContainer = View()

  let titleLabel = UILabel.small

  let pauseButton = UIButton.small()
    .with(title: "Пауза")
    .with(selectedTitleColor: .red)

  let muteButton = UIButton.small()
    .with(title: "Заглушить")
    .with(selectedTitleColor: .red)

  let deleteButton = UIButton.small()
    .with(backgroundColor: .systemRed)
    .with(title: "Удалить")
    .with(selectedTitleColor: .red)

  let loudnessSlider = SliderView(title: "Громкость", bounds: 0...10)
  let silenceLengthSlider = SliderView(title: "Скорость", bounds: 0...1)

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(channel: AudioChannel) {
    self.channel = channel

    super.init()

    setupLayout()

    onTap(of: pauseButton) { $0.pauseButtonTapped() }
    onTap(of: muteButton) { $0.muteButtonTapped() }

    setupSliders()
  }

  private func setupLayout() {
    backgroundColor = .systemTeal

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
      $0.top.bottom.leading.equalToSuperview()
    }

    buttonsContainer.addSubview(pauseButton)
    pauseButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
    }

    buttonsContainer.addSubview(muteButton)
    muteButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(pauseButton.snp.trailing).offset(16)
    }

    buttonsContainer.addSubview(deleteButton)
    deleteButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(muteButton.snp.trailing).offset(16)
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
    updateSliders()

    silenceLengthSlider.value
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] newSilenceLength in
        self?.silenceLengthSliderValueChanged(newValue: newSilenceLength)
      })
      .disposed(by: disposeBag)

    loudnessSlider.value
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] newLoudness in
        self?.loudnessSliderValueChanged(newValue: newLoudness)
      })
      .disposed(by: disposeBag)
  }

  private func channelUpdated() {
    titleLabel.text = channel.segment.sample.name
    pauseButton.isSelected = channel.isPaused
    muteButton.isSelected = channel.isMuted
  }

  private func onTap(of button: UIButton,
                     tapHandler: @escaping (AudioChannelView) -> Void) {
    button.rx.tap
      .subscribe(onNext: { [weak self] _ in self.map(tapHandler) })
      .disposed(by: disposeBag)
  }

  private func pauseButtonTapped() {
    emitChannelEvent(.isPaused(channel: channel, isPaused: !channel.isPaused))
  }

  private func muteButtonTapped() {
    emitChannelEvent(.isMuted(channel: channel, isMuted: !channel.isMuted))
  }

  private func silenceLengthSliderValueChanged(newValue: Float) {
    emitChannelEvent(.silenceLengthChanged(
      channel: channel,
      newSilenceLength: CGFloat(newValue)
    ))
  }

  private func loudnessSliderValueChanged(newValue: Float) {
    emitChannelEvent(.loudnessChanged(
      channel: channel,
      newLoudness: Int(newValue * 100)
    ))
  }

  private func emitChannelEvent(_ event: AudioChannelEvent) {
    channelEvent.onNext(event)
    channel = event.apply(to: channel)
    channelUpdated()
  }

  func with(channel: AudioChannel) -> Self {
    self.channel = channel
    channelUpdated()
    updateSliders()
    return self
  }

  private func updateSliders() {
    silenceLengthSlider.isHidden = !channel.segment.sample.canBeRepeated
    _ = loudnessSlider.with(value: Float(channel.segment.loudness) / 100)
    _ = silenceLengthSlider.with(value: Float(channel.segment.silenceLength))
  }
}

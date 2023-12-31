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

  let pauseButton = UIButton.iconic(
    image: .smallPauseIcon,
    tintColor: .black,
    width: 44
  )
  .with(image: .smallPlayIcon, forState: .selected)

  let muteButton = UIButton.iconic(
    image: .smallUnmuteIcon,
    tintColor: .black,
    width: 44
  )

  let deleteButton = UIButton.iconic(
    image: .smallDeleteIcon,
    tintColor: .black,
    width: 44
  )

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
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-16)
      $0.top.equalTo(buttonsContainer.snp.bottom)
    }

    setupSlidersLayout()
  }

  private func setupButtonsLayout() {
    buttonsContainer.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
    }

    let stack = UIStackView().preparedForAutoLayout()
    stack.axis = .horizontal
    stack.addArrangedSubview(pauseButton)
    stack.addArrangedSubview(muteButton)
    stack.addArrangedSubview(deleteButton)

    buttonsContainer.addSubview(stack)
    stack.snp.makeConstraints {
      $0.top.bottom.trailing.equalToSuperview()
      $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
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
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] newSliderValue in
        self?.silenceLengthSliderValueChanged(newValue: newSliderValue)
      })
      .disposed(by: disposeBag)

    loudnessSlider.value
      .compactMap { $0 }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] newLoudness in
        self?.loudnessSliderValueChanged(newValue: newLoudness)
      })
      .disposed(by: disposeBag)
  }

  private func channelUpdated() {
    titleLabel.text = channel.segment.sample.name
    pauseButton.isSelected = channel.isPaused
    muteButton.isSelected = channel.isMuted
    updateMuteButton()
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
    muteButton.isSelected = !channel.isMuted
    updateMuteButton()

    emitChannelEvent(.isMuted(channel: channel, isMuted: !channel.isMuted))
  }

  private func updateMuteButton() {
    muteButton.tintColor = muteButton.isSelected ? .black.withAlphaComponent(0.25) : .black
  }

  private func silenceLengthSliderValueChanged(newValue: Float) {
    emitChannelEvent(.silenceLengthChanged(
      channel: channel,
      newSilenceLength: toSilenceLength(newValue)
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
    _ = silenceLengthSlider.with(value: fromSilenceLength(channel.segment.silenceLength))
  }

  private func toSilenceLength(_ sliderValue: Float) -> CGFloat {
    guard sliderValue >= 0.05 else { return 10_000_000_000 }

    return CGFloat((1 - sliderValue) * 5)
  }

  private func fromSilenceLength(_ silenceLength: CGFloat) -> Float {
    // x = (1 - y) * 5
    // -5y + 5 = x
    // y = (x - 5) / -5
    // y = (5 - x) / 5
    guard silenceLength <= 5 else { return 0 }
    return Float((5 - silenceLength) / 5).clamped(inside: 0...1)
  }
}

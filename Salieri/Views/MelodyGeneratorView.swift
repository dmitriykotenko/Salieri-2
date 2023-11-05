// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class MelodyGeneratorView: View {

  var onPlayStarted: () -> Void = {}
  var onPlayFinished: () -> Void = {}
  var onFramesGenerated: (FramesPack) -> Void = { _ in }

  let bottomButtonsPanel = View()

  let spacer = View()

  let playButton = UIButton.iconic(image: .largePlayIcon, tintColor: .systemTeal)
  let recordButton = UIButton.iconic(image: .largeRecordIcon, tintColor: .systemRed)
  let stopButton = UIButton.iconic(image: .largeStopIcon, tintColor: .systemTeal)
  let micButton = UIButton.iconic(image: .largeMicIcon, tintColor: .systemTeal)

  private var melodyContainer: MelodyContainer

  private var melodyGenerator: MelodyGenerator?

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(melodyContainer: MelodyContainer) {
    self.melodyContainer = melodyContainer

    super.init()

    setupLayout()

    playButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.play() })
      .disposed(by: disposeBag)

    recordButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.record() })
      .disposed(by: disposeBag)

    stopButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.stop() })
      .disposed(by: disposeBag)

    micButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.melodyContainer.isMicMuted.toggle()
        self?.micButton.isSelected.toggle()
        self?.micButtonUpdated()
      })
      .disposed(by: disposeBag)

    stopButton.isHidden = true

    micButtonUpdated()
  }

  private func setupLayout() {
    addSubview(bottomButtonsPanel)

    safeAreaLayoutGuide.snp.makeConstraints {
      $0.leading.trailing.top.bottom.equalTo(bottomButtonsPanel)
    }

    bottomButtonsPanel.snp.makeConstraints {
      $0.height.equalTo(44)
    }

    let stack = UIStackView().preparedForAutoLayout()
    stack.axis = .horizontal

    [playButton, stopButton, recordButton, micButton].forEach {
      stack.addArrangedSubview($0)
    }

    bottomButtonsPanel.addSubview(stack)
    stack.snp.makeConstraints {
      $0.top.bottom.centerX.equalToSuperview()
    }
  }

  private func micButtonUpdated() {
    micButton.tintColor = micButton.tintColor.withAlphaComponent(micButton.isSelected ? 1 : 0.5)
  }

  private func play(saveToFile fileName: String? = nil) {
    playButton.isHidden = true
    recordButton.isHidden = true
    stopButton.isHidden = false

    self.melodyGenerator = MelodyGenerator(
      melodyContainer: melodyContainer,
      parentViewController: containingViewController,
      shouldShareRecordedMelody: true
    )

    self.melodyGenerator?.onFramesGenerated = onFramesGenerated

    Task { @MainActor in
      await melodyGenerator?.play(
        totalDuration: 36000.seconds,
        saveToFile: fileName
      )

      onPlayStarted()
    }
  }

  private func record() {
    play(saveToFile: "salieri-very-first-file.wav")
  }

  private func stop() {
    melodyGenerator?.stop()

    playButton.isHidden = false
    recordButton.isHidden = false
    stopButton.isHidden = true

    onPlayFinished()
  }
}

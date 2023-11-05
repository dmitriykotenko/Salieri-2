// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class MelodyGeneratorView: View {

  var onFramesGenerated: (FramesPack) -> Void = { _ in }

  let bottomButtonsPanel = View()

  let playButton = UIButton.standard.with(title: "Воспроизвести реквием")

  let stopButton = UIButton.standard
    .with(title: "Остановить реквием")
    .with(backgroundColor: .systemRed)

  let micButton = UIButton.standard
    .with(title: "Микрофон")
    .with(titleColor: .gray, forState: .normal)
    .with(backgroundColor: .systemGreen)
    .with(selectedTitleColor: .white)

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

    stopButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.stop() })
      .disposed(by: disposeBag)

    micButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.melodyContainer.isMicMuted.toggle()
        self?.micButton.isSelected.toggle()
      })
      .disposed(by: disposeBag)

    stopButton.isEnabled = false
  }

  private func setupLayout() {
    addSubview(bottomButtonsPanel)

    safeAreaLayoutGuide.snp.makeConstraints {
      $0.leading.trailing.top.bottom.equalTo(bottomButtonsPanel)
    }

    bottomButtonsPanel.snp.makeConstraints {
      $0.height.equalTo(150)
    }

    bottomButtonsPanel.addSubview(playButton)
    playButton.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    bottomButtonsPanel.addSubview(stopButton)
    stopButton.snp.makeConstraints {
      $0.centerY.leading.trailing.equalToSuperview()
    }

    bottomButtonsPanel.addSubview(micButton)
    micButton.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }

  private func play() {
    playButton.isEnabled = false
    stopButton.isEnabled = true

    self.melodyGenerator = MelodyGenerator(
      melodyContainer: melodyContainer,
      parentViewController: containingViewController
    )

    self.melodyGenerator?.onFramesGenerated = onFramesGenerated

    Task { @MainActor in
      await melodyGenerator?.play(
        totalDuration: 36000.seconds,
        saveToFile: "salieri-very-first-file.wav"
      )
    }
  }

  private func stop() {
    melodyGenerator?.stop()

    stopButton.isEnabled = false
    playButton.isEnabled = true
  }
}

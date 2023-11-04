// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class MelodyGeneratorView: View {

  let bottomButtonsPanel = View()

  let playButton = UIButton.standard.with(title: "Воспроизвести реквием")

  let stopButton = UIButton.standard
    .with(title: "Остановить реквием")
    .with(backgroundColor: .systemRed)

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

    stopButton.isEnabled = false
  }

  private func setupLayout() {
    addSubview(bottomButtonsPanel)

    safeAreaLayoutGuide.snp.makeConstraints {
      $0.leading.trailing.top.bottom.equalTo(bottomButtonsPanel)
    }

    bottomButtonsPanel.snp.makeConstraints {
      $0.height.equalTo(100)
    }

    bottomButtonsPanel.addSubview(playButton)
    playButton.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    bottomButtonsPanel.addSubview(stopButton)
    stopButton.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }

  private func play() {
    playButton.isEnabled = false
    stopButton.isEnabled = true

    self.melodyGenerator = MelodyGenerator(
      melodyContainer: melodyContainer
    )

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

// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class MicRecorderView: View {

  var onFinish: (AudioSample?) -> Void = { _ in }

  let progressView = MelodyProgressView()
  let visualisationView = SoundVisualisationView()
  let stopButton = UIButton.iconic(image: .stopIcon, tintColor: .systemTeal)

  let cancelButton = UIButton.standard
    .with(title: "Отмена")
    .with(titleColor: .systemTeal, forState: .normal)

  private let melodyContainer = MelodyContainer()

  private lazy var recordingSpec: MicRecordingsStorage.MicRecordingSpec = recordingsStorage.nextRecordingSpec

  private var melodyGenerator: MelodyGenerator?
  private let recordingsStorage = MicRecordingsStorage()

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init() {
    super.init()

    setupLayout()

    stopButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.stop(shouldCancel: false) })
      .disposed(by: disposeBag)

    cancelButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.stop(shouldCancel: true) })
      .disposed(by: disposeBag)
  }

  private func setupLayout() {
    backgroundColor = .systemBlue

    let topStack = UIStackView().preparedForAutoLayout()
    topStack.axis = .vertical

    topStack.addArrangedSubview(progressView)
    topStack.addArrangedSubview(visualisationView)

    addSubview(topStack)
    topStack.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
    }

    let buttonsStack = UIStackView().preparedForAutoLayout()
    buttonsStack.axis = .horizontal
    buttonsStack.spacing = 16
    buttonsStack.addArrangedSubview(stopButton)
    buttonsStack.addArrangedSubview(cancelButton)

    addSubview(buttonsStack)
    buttonsStack.snp.makeConstraints {
      $0.bottom.centerX.equalTo(safeAreaLayoutGuide)
    }
  }

  func record() {
    melodyGenerator = MelodyGenerator(
      melodyContainer: melodyContainer,
      parentViewController: containingViewController,
      shouldShareRecordedMelody: false
    )

    melodyGenerator?.onFramesGenerated = { [weak self] in
      self?.visualisationView.add(
        rawFrames: $0.rawFrames,
        rawFrameRate: $0.frameRate,
        setCurrentDuration: $0.currentDuration
      )

      self?.progressView.currentDuration = $0.currentDuration
    }

    melodyContainer.isMicMuted = false

    Task { @MainActor in
      await melodyGenerator?.play(
        totalDuration: 36000.seconds,
        saveToFile: recordingSpec.fileName
      )
    }

    progressView.isHidden = false
    visualisationView.isHidden = false
    stopButton.isHidden = false
    cancelButton.isHidden = false
  }

  func stop(shouldCancel: Bool) {
    melodyGenerator?.stop()

    progressView.isHidden = true
    visualisationView.isHidden = true
    stopButton.isHidden = true
    cancelButton.isHidden = true

    visualisationView.reset()

    if shouldCancel || progressView.currentDuration! <= 100.milliseconds {
      try? FileManager.default.removeFile(name: recordingSpec.fileName)
      onFinish(nil)
    } else {
      onFinish(
        .init(
          instrumentKind: .mic,
          name: recordingSpec.name,
          shortName: recordingSpec.shortName,
          summary: "Recording date: \(Date())",
          fileName: .recorded(
            FileManager.default.fileUrl(fileName: recordingSpec.fileName)!
          )
        )
      )

      recordingSpec = recordingsStorage.nextRecordingSpec
    }
  }
}

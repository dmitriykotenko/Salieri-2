// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class ViewController: UIViewController {

  let titleLabel = UILabel.standard.with(text: "Сальери")
  let button = UIButton.standard.with(title: "Сочинить реквием")
  let playButton = UIButton.standard.with(title: "Воспроизвести реквием")
  let doneLabel = UILabel.standard.with(textColor: .systemTeal).with(text: "Реквием сочинён")

  let channelView = AudioChannelView()

  private var wavPlayer: AVAudioPlayer?
  private var melodyGenerator: MelodyGenerator?

  private var audioChannelPlayer: AudioChannelPlayer?

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupLayout()

    _ = channelView.with(
      channel: .init(
        segment: .init(
          sample: .eMinSwellingPad,
          loudness: 500,
          silenceLength: 0
        )
      )
    )

    button.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.setupChannelPlaying()
//        self?.doneLabel.isHidden = false
//        self?.playButton.isHidden = false
      })
      .disposed(by: disposeBag)

    playButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.playRequiem2() })
      .disposed(by: disposeBag)
  }

  private func setupLayout() {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemOrange.withAlphaComponent(0.5)

    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(50)
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
    }

    view.addSubview(button)
    button.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
    }

    doneLabel.isHidden = true
    view.addSubview(doneLabel)
    doneLabel.snp.makeConstraints {
      $0.top.equalTo(button.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
    }

    playButton.isHidden = true
    view.addSubview(playButton)
    playButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
      $0.top.equalTo(doneLabel.snp.bottom).offset(16)
    }

    view.addSubview(channelView)
    channelView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
      $0.top.equalTo(playButton.snp.bottom).offset(16)
    }
  }

  private func playWavFile() {
    let fileUrl = wavUrl(fileName: "e-min-swelling-pad")

    let player = fileUrl.flatMap { try? AVAudioPlayer(contentsOf: $0) }
    player?.play()

    self.wavPlayer = player
  }

  private func playRequiem2() {
    self.melodyGenerator = MelodyGenerator(
      segments: [
        .init(
          sample: .d80811,
          loudness: 450,
          silenceLength: 0
        ),
        .init(
          sample: .d80811,
          loudness: 900,
          silenceLength: 3
        ),
        .init(
          sample: .eMinSwellingPad,
          loudness: 500,
          silenceLength: 0
        ),
//        .init(
//          sample: .cMinBass,
//          loudness: 200,
//          silenceLength: 0
//        ),
      ]
    )

    Task { @MainActor in
      await melodyGenerator?.play(
        totalDuration: 15.seconds,
        saveToFile: "salieri-very-first-file.wav"
      )
    }
  }

  private func createRequiem() {}

  private func wavUrl(fileName: String) -> URL? {
    let filePath = Bundle.main.path(forResource: "e-min-swelling-pad", ofType: "wav")
    return filePath.map { URL(filePath: $0) }
  }

  private func setupChannelPlaying() {
    audioChannelPlayer = .init(
      channel: .init(
        segment: .init(
          sample: .eMinSwellingPad,
          loudness: 100,
          silenceLength: 0
        )
      )
    )

    Task {
      await audioChannelPlayer?.play(totalDuration: 100.seconds)
    }

    channelView.channel
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] in
        self?.audioChannelPlayer?.channel = $0
      })
      .disposed(by: disposeBag)
  }
}

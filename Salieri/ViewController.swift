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

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
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

    button.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.doneLabel.isHidden = false
        self?.playButton.isHidden = false
      })
      .disposed(by: disposeBag)

    playButton.rx.tap
      .subscribe(onNext: { [weak self] in self?.playRequiem() })
      .disposed(by: disposeBag)
  }

  private func playRequiem() {
    let fileUrl = wavUrl(fileName: "e-min-swelling-pad")

    let player = fileUrl.flatMap { try? AVAudioPlayer(contentsOf: $0) }
    player?.play()

    self.player = player
  }

  private func createRequiem() {}

  private func wavUrl(fileName: String) -> URL? {
    let filePath = Bundle.main.path(forResource: "e-min-swelling-pad", ofType: "wav")
    return filePath.map { URL(filePath: $0) }
  }

  private var player: AVAudioPlayer?
}

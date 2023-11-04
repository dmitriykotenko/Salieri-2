// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class ViewController: UIViewController {

  let titleLabel = UILabel.standard
    .with(textColor: .white)
    .with(text: "Сальери")
    .with(textAlignment: .center)

  let scrollView = UIScrollView().preparedForAutoLayout()

  let melodyContainer = MelodyContainer(channels: [
    .init(segment: .init(sample: .cMinBass)),
    .init(segment: .init(sample: .eMinSwellingPad))
  ])

  lazy var channelsView = AudioChannelsView(melodyContainer: melodyContainer)
  lazy var generatorView = MelodyGeneratorView(melodyContainer: melodyContainer)

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupLayout()
  }

  private func setupLayout() {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .mainBackground

    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(50)
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
    }

    addMelodyGeneratorView()
    addChannelsView()
  }

  private func addMelodyGeneratorView() {
    view.addSubview(generatorView)

    generatorView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }

  private func addChannelsView() {
    scrollView.addSubview(channelsView)
    view.addSubview(scrollView)

    channelsView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(300)
      $0.leading.bottom.equalToSuperview()
      $0.width.equalTo(view)
    }
    
    scrollView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(generatorView.snp.top).inset(-16)
      $0.top.equalTo(titleLabel.snp.bottom).inset(-16)
    }
  }
}

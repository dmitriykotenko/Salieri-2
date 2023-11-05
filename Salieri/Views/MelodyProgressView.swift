// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class MelodyProgressView: View {

  var currentDuration: Duration? { didSet { update() } }
  var isRecording: Bool = false { didSet { update() } }
  var isPlaying: Bool = false { didSet { update() } }

  private func update() {
    DispatchQueue.main.async {
      self.updateImmediately()
    }
  }

  private func updateImmediately() {
    isHidden = !isPlaying
    recordingView.isHidden = !isRecording

    let floatDuration = CGFloat((currentDuration ?? .zero).milliseconds) / 1000
    durationLabel.text =
      NumberFormatter.melodyProgress.string(from: floatDuration as NSNumber)?.appending(" сек.")
  }

  let recordingView = {
    let view = View(
      alignmentRectInsets: .init(top: -1, left: 0, bottom: 1, right: 0)
    )

    let radius: CGFloat = 6
    view.snp.makeConstraints { $0.width.height.equalTo(2 * radius) }
    view.layer.cornerRadius = radius
    view.backgroundColor = .systemRed

    return view
  }()

  let durationLabel = UILabel.standardWithMonospacedDigits
    .with(textColor: .melodyVisualisationStroke)

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init() {
    super.init()

    setupLayout()
    updateImmediately()
  }

  private func setupLayout() {
    let stack = UIStackView().preparedForAutoLayout()
    stack.axis = .horizontal
    stack.spacing = 8
    stack.alignment = .center

    stack.addArrangedSubview(recordingView)

    durationLabel.setContentHuggingPriority(.required, for: .horizontal)
    durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    stack.addArrangedSubview(durationLabel)

    addSubview(stack)
    stack.snp.makeConstraints { $0.top.bottom.centerX.equalToSuperview() }
  }
}

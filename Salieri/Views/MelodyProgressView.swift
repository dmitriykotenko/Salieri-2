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

  func reset() {
    currentDuration = nil
  }

  private func update() {
    DispatchQueue.main.async {
      self.updateImmediately()
    }
  }

  private func updateImmediately() {
    isHidden = !isPlaying
    recordingView.isHidden = !isRecording

    let components = (currentDuration ?? .zero).prepareToFormat

    durationLabel.text = textFrom(
      hours: components.hours,
      minutes: components.minutes,
      seconds: components.seconds,
      thousandths: components.thousandths
    ).appending(" сек.")
  }

  private func textFrom(hours: Int,
                        minutes: Int,
                        seconds: Int,
                        thousandths: Int) -> String {
    let startWithHours = hours > 0
    let startWithMinutes = !startWithHours && (minutes > 0)
    let startWithSeconds = !startWithHours && !startWithMinutes

    let deciSeconds = thousandths / 100

    if startWithHours {
      return String(format: "%d:%02d:%02d,%1d", hours, minutes, seconds, deciSeconds)
    } else if startWithMinutes {
      return String(format: "%d:%02d,%1d", minutes, seconds, deciSeconds)
    } else {
      return String(format: "%d,%1d", seconds, deciSeconds)
    }
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

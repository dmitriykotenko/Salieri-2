// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AudioSamplePickerView: Control {

  lazy var audioSample = BehaviorSubject<AudioSample?>(value: samples[0])
  lazy var audioSamplePicked = PublishSubject<AudioSample>()
  lazy var micTapped = PublishSubject<Void>()

  private let instrumentKind: MusicalInstrumentKind
  private let samples: [AudioSample]

  private lazy var kindView = MusicalInstrumentKindView(instrumentKind: instrumentKind)
  private lazy var samplesView = VerticalAudioSamplesListView(samples: samples)

  private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
  private lazy var longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap))

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(instrumentKind: MusicalInstrumentKind,
       samples: [AudioSample]) {
    self.instrumentKind = instrumentKind
    self.samples = samples

    super.init(
      isTransparentForGestures: true,
      alignmentRectInsets: .init(top: 200, left: 0, bottom: 0, right: 0)
    )

    setupLayout()
    setupSamplesView()
    setupGestures()
  }

  private func setupLayout() {
    backgroundColor = .systemTeal.withAlphaComponent(0)
    clipsToBounds = false

    addSubview(kindView)
    kindView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    samplesView.isHidden = true
    insertSubview(samplesView, belowSubview: kindView)
    samplesView.snp.makeConstraints {
      $0.centerX.equalTo(kindView)
      $0.bottom.equalTo(kindView.snp.top).offset(16)
    }
  }

  private func setupSamplesView() {
    samplesView.audioSamplePicked
      .subscribe(onNext: { [weak self] in self?.samplePickedFromList($0) })
      .disposed(by: disposeBag)
  }

  private func setupGestures() {
    kindView.addGestureRecognizer(tapGesture)
    kindView.addGestureRecognizer(longTapGesture)
  }

  @objc
  private func onTap() {
    samplesView.isHidden = true
    if instrumentKind != .mic {
      samplePicked(samples[0])
    } else {
      micTapped.onNext(())
    }
  }

  private func samplePickedFromList(_ sample: AudioSample) {
    samplesView.isHidden = true
    samplePicked(sample)
  }

  private func samplePicked(_ sample: AudioSample) {
    audioSample.onNext(sample)
    audioSamplePicked.onNext(sample)
  }

  @objc
  private func onLongTap() {
    if instrumentKind != .mic {
      samplesView.isHidden = false
    }
  }

  func onGlobalTouch(at point: CGPoint) {
    guard let window else { return }
    let samplesViewFrame = window.convert(samplesView.frame, from: self)

    if !samplesViewFrame.contains(point) {
      samplesView.isHidden = true
    }
  }
}

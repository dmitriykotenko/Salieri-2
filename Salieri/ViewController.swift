// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class ViewController: UIViewController {

  let micRecorder = MicRecorderView()
  let melodyProgressView = MelodyProgressView()
  let soundVisualisationView = SoundVisualisationView()

  let scrollView = UIScrollView().preparedForAutoLayout()

  let melodyContainer = MelodyContainer(channels: [
    .init(segment: .init(sample: .d80811)),
    .init(segment: .init(sample: .cMinBass)),
    .init(segment: .init(sample: .eMinSwellingPad))
  ])

  lazy var channelDemonstrator = AudioChannelDemonstrator(parentViewController: self)

  lazy var channelsView = AudioChannelsView(melodyContainer: melodyContainer)
  lazy var generatorView = MelodyGeneratorView(melodyContainer: melodyContainer)

  lazy var addChannelView = AddAudioChannelView()

  private let disposeBag = DisposeBag()

  override func loadView() {
    let view = TouchAwareView()
    view.onTouch = onGlobalTouch
    self.view = view
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupLayout()

    addChannelView.channelAdded
      .subscribe(onNext: { [weak self] in
        self?.onChannelAdded($0)
      })
      .disposed(by: disposeBag)

    addChannelView.micTapped
      .subscribe(onNext: { [weak self] in
        self?.onMicInstrumentTapped()
      })
      .disposed(by: disposeBag)

    generatorView.onPlayStarted = { [weak self] in
      self?.channelDemonstrator.stop()
      self?.soundVisualisationView.isHidden = false
      self?.channelsView.update()
    }

    generatorView.onPlayFinished = { [weak self] in
      self?.soundVisualisationView.isHidden = true
      self?.soundVisualisationView.reset()
      self?.melodyProgressView.reset()
      self?.channelsView.update()
    }

    generatorView.onFramesGenerated = { [weak self] in
      self?.soundVisualisationView.add(
        rawFrames: $0.rawFrames,
        rawFrameRate: $0.frameRate,
        setCurrentDuration: $0.currentDuration
      )

      self?.melodyProgressView.currentDuration = $0.currentDuration
    }

    melodyContainer.stateUpdated
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [melodyProgressView, melodyContainer] in
        melodyProgressView.isPlaying = melodyContainer.isPlaying
        melodyProgressView.isRecording = melodyContainer.isRecoring
      })
      .disposed(by: disposeBag)

    setupChannelDemonstration()
  }

  private func setupLayout() {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .mainBackground

    view.addSubview(melodyProgressView)
    melodyProgressView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
    }

    soundVisualisationView.backgroundColor = .mainBackground
    view.addSubview(soundVisualisationView)
    soundVisualisationView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(66)
      $0.top.equalTo(melodyProgressView.snp.bottom)
    }

    addMelodyGeneratorView()
    addAddChannelView()
    addChannelsView()

    micRecorder.isHidden = true
    view.addSubview(micRecorder)
    micRecorder.snp.makeConstraints { $0.edges.equalToSuperview() }
  }

  private func addMelodyGeneratorView() {
    view.addSubview(generatorView)

    generatorView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }

  private func addAddChannelView() {
    view.addSubview(addChannelView)
    addChannelView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(generatorView.snp.top).offset(-16)
    }
  }

  private func addChannelsView() {
    scrollView.addSubview(channelsView)
    view.insertSubview(scrollView, belowSubview: addChannelView)

    channelsView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(300)
      $0.leading.bottom.equalToSuperview()
      $0.width.equalTo(view)
    }
    
    scrollView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(addChannelView.snp.top).inset(-16)
      $0.top.equalTo(soundVisualisationView.snp.bottom).inset(-16)
    }
  }

  private func onChannelAdded(_ channel: AudioChannel) {
    channelsView.channelAdded(channel)
  }

  private func onMicInstrumentTapped() {
    micRecorder.isHidden = false

    micRecorder.onFinish = { [weak self] audioSample in
      if let audioSample {
        self?.channelsView.channelAdded(.init(
          segment: .unrepeatable(sample: audioSample)
        ))
      }

      self?.micRecorder.isHidden = true
    }

    micRecorder.record()
  }

  private var demonstratedChannelId: UUID?

  private func setupChannelDemonstration() {
    melodyContainer.channelEvents
      .filter { [weak self] _ in self?.melodyContainer.isPlaying == false }
      .observe(on: MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] in
        switch $0 {
        case .isPaused(let channel, let isPaused):
          let shouldPlayNewChannel = !isPaused && channel.id != self?.demonstratedChannelId
          let shouldStopCurrenChannel = isPaused && (channel.id == self?.demonstratedChannelId)

          guard shouldPlayNewChannel || shouldStopCurrenChannel else { break }

          if isPaused {
            self?.stopChannelDemonstration()
          } else {
            self?.demonstrateChannel(channel)
          }
        default:
          if self?.demonstratedChannelId == $0.initialChannel.id {
            self?.channelDemonstrator.onChannelEvent($0)
          }
        }
      })
      .disposed(by: disposeBag)
  }

  private func demonstrateChannel(_ channel: AudioChannel) {
    demonstratedChannelId = channel.id

    channelDemonstrator.stop()
    melodyContainer.prepareToDemonstrate(channel: channel)

    Task {
      await channelDemonstrator.play(channel: channel, totalDuration: 600.seconds)
      channelsView.update()
    }
  }

  private func stopChannelDemonstration() {
    channelDemonstrator.stop()
    melodyContainer.prepareToStop()
    channelsView.update()
    demonstratedChannelId = nil
  }

  @objc
  private func onGlobalTouch(location: CGPoint) {
    print("global-touch")
    addChannelView.onGlobalTouch(at: location)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    .lightContent
  }
}


class TouchAwareView: UIView {

  var onTouch: (CGPoint) -> Void = { _ in }

  override func hitTest(_ point: CGPoint,
                        with event: UIEvent?) -> UIView? {
    onTouch(point)
    return super.hitTest(point, with: event)
  }
}

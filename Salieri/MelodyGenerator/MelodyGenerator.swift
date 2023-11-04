// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift
import UIKit


class MelodyGenerator {

  let audioSession = AVAudioSession.sharedInstance()
  let audioEngine = AVAudioEngine()

  var melodyContainer: MelodyContainer
  var state: MelodyGeneratorState
  var channelPlayers: [AudioChannelPlayer] = []

  private weak var parentViewController: UIViewController?
  private var sharer: MelodySharer?
  private var melodyFileName: String?

  private let disposeBag = DisposeBag()

  init(melodyContainer: MelodyContainer,
       parentViewController: UIViewController?) {
    self.melodyContainer = melodyContainer
    self.parentViewController = parentViewController

    state = .init(
      channels: melodyContainer.channels,
      isPlayingMelody: true,
      baseTime: .zero
    )

    melodyContainer.channelEvents
      .subscribe(onNext: { [weak self] in self?.process(channelEvent: $0) })
      .disposed(by: disposeBag)

    setupAudioEngine()
    listenForAudioRouteChanges()
  }


  func play(totalDuration: Duration,
            saveToFile fileName: String? = nil) async {
    melodyContainer.isPlaying = true

    self.channelPlayers = state.channels.map {
      AudioChannelPlayer(
        audioSession: audioSession,
        audioEngine: audioEngine,
        channel: $0
      )
    }

    _ = await channelPlayers.asyncMap {
      await $0.prepareToPlay(totalDuration: totalDuration)
    }

    audioEngine.prepare()

    try! audioEngine.start()

    fileName.map(setupFileSaving)

    channelPlayers.forEach { $0.play(totalDuration: totalDuration) }
  }

  func stop() {
    channelPlayers.forEach { $0.playerNode?.stop() }
    audioEngine.mainMixerNode.removeTap(onBus: 0)
    melodyContainer.isPlaying = false
    share()
  }

  func share() {
    sharer = .init(parentViewController: parentViewController)

    if let melodyFileName {
      sharer?.shareMelody(fileName: melodyFileName)
    }
  }

  private func synchronizeChannelsAndStartPlaying() {
    channelPlayers.forEach { $0.playerNode?.prepare(withFrameCount: 8192) }

    let hostTimeNow = mach_absolute_time()
    let hostTimeFuture = hostTimeNow + AVAudioTime.hostTime(forSeconds: 0.25);

    // Небольшая задержка, чтобы все каналы начали играть строго одновременно.
    let startTime = AVAudioTime(hostTime: hostTimeFuture)

    channelPlayers.forEach { $0.playerNode?.play(at: startTime) }
  }

  private func setupFileSaving(fileName: String) {
    guard let fileUrl = FileManager.default.fileUrl(fileName: fileName) else { return }

    let bus: AVAudioNodeBus = 0

    let audioFormat = audioEngine.mainMixerNode.outputFormat(forBus: bus)

    let audioFile = try! AVAudioFile(
      forWriting: fileUrl,
      settings: audioFormat.settings
    )

    audioEngine.mainMixerNode.installTap(
      onBus: bus,
      bufferSize: 4096,
      format: audioFormat,
      block: { buffer, time in
        try! audioFile.write(from: buffer)
      }
    )

    melodyFileName = fileName
  }

  func process(melodyEvent: MelodyEvent) {
    if state.isPlayingMelody {
      switch melodyEvent {
      case .channelAdded(let newChannel):
        state.channels += [newChannel]
      case .channelDeleted(let id):
        state.channels = state.channels.filter { $0.id != id }
      case .channelChange(let channelEvent):
        state.channels = state.channels.map {
          $0.id == channelEvent.initialChannel.id ? channelEvent.apply(to: $0) : $0
        }
      }
    } else {
      switch melodyEvent {
      case .channelAdded, .channelDeleted:
        break
      case .channelChange(let channelEvent):
        process(channelEvent: channelEvent)
      }
    }
  }

  private func process(channelEvent: AudioChannelEvent) {
    let channelIndex = state.channels.firstIndex { $0.id == channelEvent.initialChannel.id }
    let channelPlayer = channelIndex.map { channelPlayers[$0] }
    channelPlayer?.process(audioChannelEvent: channelEvent)
  }

  private func setupAudioEngine() {
    try! activateAudioSession()
//    try! audioEngine.start()
  }

  private func activateAudioSession() throws {
    try audioSession.setCategory(.playAndRecord)
//    try audioSession.overrideOutputAudioPort(.speaker)
    try audioSession.setActive(true)
  }

  private func listenForAudioRouteChanges() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onAudioSessionRouteChange),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )
  }

  @objc
  private func onAudioSessionRouteChange() {
    setupAudioEngine()
  }
}

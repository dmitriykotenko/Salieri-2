// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift
import UIKit


class AudioChannelDemonstrator {

  let audioSession = AVAudioSession.sharedInstance()
  let audioEngine = AVAudioEngine()

  private var melodyContainer: MelodyContainer?
  var channelPlayer: AudioChannelPlayer?
  var micPlayer: MicPlayer?

  var pcmBufferParser: PcmBufferParser?

  var onFramesGenerated: (FramesPack) -> Void = { _ in }

  private weak var parentViewController: UIViewController?
  private var sharer: MelodySharer?
  private var melodyFileName: String?

  private let disposeBag = DisposeBag()

  init(parentViewController: UIViewController?) {
    self.parentViewController = parentViewController

    setupAudioEngine()
    listenForAudioRouteChanges()
  }

  func onChannelEvent(_ channelEvent: AudioChannelEvent) {
    switch channelEvent {
    case .isPaused(let channel, let isPaused):
      if isPaused {
        stop()
      } else {
        stop()
        Task {
          await play(channel: channel, totalDuration: 600.seconds)
        }
      }
    default:
      break
    }
  }

  func play(channel: AudioChannel,
            totalDuration: Duration) async {
    melodyContainer = .init(channels: [channel])
    melodyContainer?.isPlaying = true

    self.channelPlayer = AudioChannelPlayer(
      audioSession: audioSession,
      audioEngine: audioEngine,
      channel: channel
    )

    await channelPlayer?.prepareToPlay(totalDuration: totalDuration)

    audioEngine.prepare()

    try! audioEngine.start()

    setupFrameBufferListening(fileName: nil)

    channelPlayer?.play(totalDuration: totalDuration)
  }

  func stop() {
    channelPlayer?.playerNode?.stop()
    audioEngine.mainMixerNode.removeTap(onBus: 0)
    melodyContainer?.isPlaying = false

  }

  private func setupFrameBufferListening(fileName: String?) {
    let fileUrl = fileName.flatMap { FileManager.default.fileUrl(fileName: $0) }

    let bus: AVAudioNodeBus = 0

    let audioFormat = audioEngine.mainMixerNode.outputFormat(forBus: bus)

    let audioFile = fileUrl.flatMap {
      try! AVAudioFile(
        forWriting: $0,
        settings: audioFormat.settings
      )
    }

    pcmBufferParser = .init()

    var currentDuration = Duration.zero
    audioEngine.mainMixerNode.installTap(
      onBus: bus,
      bufferSize: 1024,
      format: audioFormat,
      block: { [weak self] buffer, time in
        currentDuration = currentDuration + 100.milliseconds
        print("now-------\(Date())")
        try! audioFile?.write(from: buffer)

        if let frames = self?.pcmBufferParser?.processChunkedAudioData(buffer: buffer) {
          self?.onFramesGenerated(.init(
            rawFrames: frames,
            frameRate: 100,
            currentDuration: currentDuration
          ))
        }
      }
    )

    melodyFileName = fileName
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

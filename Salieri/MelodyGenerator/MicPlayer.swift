// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class MicPlayer {

  let audioSession: AVAudioSession
  let audioEngine: AVAudioEngine

  private let inputNode: AVAudioInputNode
  private let mainMixerNode: AVAudioMixerNode

  private(set) var playerNode: AVAudioPlayerNode?

  private let disposeBag = DisposeBag()

  init(audioSession: AVAudioSession = .sharedInstance(),
       audioEngine: AVAudioEngine = .init()) {
    self.audioSession = audioSession
    self.audioEngine = audioEngine

    self.inputNode = audioEngine.inputNode
    self.mainMixerNode = audioEngine.mainMixerNode

    setupAudioEngine()
    listenForAudioRouteChanges()
  }

  func prepareToPlay() {
    let micFormat = inputNode.inputFormat(forBus: 0)

    audioEngine.connect(
      inputNode,
      to: audioEngine.mainMixerNode,
      format: micFormat
    )
  }

  func setIsMuted(_ isMuted: Bool) {
    inputNode.volume = isMuted ? 0 : 1
  }

  func stop() {
    inputNode.engine?.stop()
  }

  private func setupAudioEngine() {
    try! activateAudioSession()

    let ioBufferDuration = 128.0 / 44100.0
    try! audioSession.setPreferredIOBufferDuration(ioBufferDuration)
  }

  private func activateAudioSession() throws {
    try audioSession.setCategory(.playAndRecord)
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

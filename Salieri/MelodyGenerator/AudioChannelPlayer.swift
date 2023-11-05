// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class AudioChannelPlayer {

  let audioSession: AVAudioSession
  let audioEngine: AVAudioEngine

  private(set) var channel: AudioChannel
  private(set) var playerNode: AVAudioPlayerNode?

  private let disposeBag = DisposeBag()

  init(audioSession: AVAudioSession = .sharedInstance(),
       audioEngine: AVAudioEngine = .init(),
       channel: AudioChannel) {
    self.audioSession = audioSession
    self.audioEngine = audioEngine
    self.channel = channel

    setupAudioEngine()
    listenForAudioRouteChanges()
  }

  func prepareToPlay(totalDuration: Duration) async {
    self.playerNode = await channel.asAudioNode(
      audioEngine: audioEngine,
      totalDuraton: totalDuration
    )
  }

  func play(totalDuration: Duration) {
    playerNode?.prepare(withFrameCount: 8192)

    let hostTimeNow = mach_absolute_time()
    let hostTimeFuture = hostTimeNow + AVAudioTime.hostTime(forSeconds: 0.25);

    // Небольшая задержка, чтобы все каналы начали играть строго одновременно.
    let startTime = AVAudioTime(hostTime: hostTimeFuture)

    playerNode?.play(at: startTime)
  }

  private func setupAudioEngine() {
    try! activateAudioSession()
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

  func process(audioChannelEvent: AudioChannelEvent) {
    switch audioChannelEvent {
    case .isMuted, .loudnessChanged:
      channel = audioChannelEvent.apply(to: channel)
      updateVolume()
    case .isPaused(_, let isPaused):
      channel = audioChannelEvent.apply(to: channel)
      isPaused ? playerNode?.pause() : playerNode?.play()
    case .sampleChanged:
      channel = audioChannelEvent.apply(to: channel)
      rescheduleSegments()
    case .silenceLengthChanged:
      processSilenceLengthChange(event: audioChannelEvent)
    }
  }

  private func processSilenceLengthChange(event: AudioChannelEvent) {
    let lastRenderedMoment = (playerNode?.lastRenderedMoment ?? .zero) % channel.segment.period
    let isSilenceNow = channel.segment.shouldBeSilent(at: lastRenderedMoment)

    channel = event.apply(to: channel)

    rescheduleSegments(
      offset: isSilenceNow ? .zero : lastRenderedMoment.negated
    )
  }

  private func rescheduleSegments(offset: Duration = .zero) {
    guard let playerNode else { return }

    playerNode.stop()

    Task {
      _ = await channel.reschedule(
        audioEngine: audioEngine,
        audioNode: playerNode,
        totalDuraton: 600.seconds,
        offset: offset
      )

      playerNode.play()
    }
  }

  private func updateVolume() {
    playerNode?.volume = channel.isMuted ? 0.3 : Float(channel.segment.loudness) / 100
  }
}


extension AVAudioPlayerNode {

  var lastRenderedMoment: Duration? {
    let audioTime = lastRenderTime.flatMap { playerTime(forNodeTime: $0) }

    return audioTime?.asDuration
  }
}

// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class AudioChannelPlayer {

  let audioSession = AVAudioSession.sharedInstance()
  let audioEngine = AVAudioEngine()

  var channel: AudioChannel {
    didSet {
      channelChange(old: oldValue, new: channel)
    }
  }

  private let disposeBag = DisposeBag()

  init(channel: AudioChannel) {
    self.channel = channel

    setupAudioEngine()
    listenForAudioRouteChanges()
  }

  var playerNode: AVAudioPlayerNode?

  func play(totalDuration: Duration,
            saveToFile fileName: String? = nil) async {
    self.playerNode = await channel.asAudioNode(
      audioEngine: audioEngine,
      totalDuraton: totalDuration
    )

    audioEngine.prepare()

    try! audioEngine.start()

    fileName.map(setupFileSaving)

    synchronizeChannelsAndStartPlaying()

//    DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration.asTimeInterval + 1) { [weak self] in
//      self?.playerNode?.stop()
//      self?.audioEngine.mainMixerNode.removeTap(onBus: 0)
//    }
  }

  private func synchronizeChannelsAndStartPlaying() {
    playerNode?.prepare(withFrameCount: 8192)

    let hostTimeNow = mach_absolute_time()
    let hostTimeFuture = hostTimeNow + AVAudioTime.hostTime(forSeconds: 0.25);

    // Небольшая задержка, чтобы все каналы начали играть строго одновременно.
    let startTime = AVAudioTime(hostTime: hostTimeFuture)

    playerNode?.play(at: startTime)
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

  private func channelChange(old: AudioChannel,
                             new: AudioChannel) {
    if new.isMuted != old.isMuted {
      onAudioChannelEvent(.isMuted(new.isMuted))
    } else if new.isPaused != old.isPaused {
      onAudioChannelEvent(.isPaused(new.isPaused))
    } else if new.segment.sample != old.segment.sample {
      onAudioChannelEvent(.sampleChanged(new.segment.sample))
    } else if new.segment.loudness != old.segment.loudness {
      onAudioChannelEvent(.loudnessChanged(new.segment.loudness))
    } else if new.segment.silenceLength != old.segment.silenceLength {
      onAudioChannelEvent(.silenceLengthChanged(new.segment.silenceLength))
    }
  }

  private func onAudioChannelEvent(_ event: AudioChannelEvent) {
    channel = event.apply(to: channel)

    switch event {
    case .isMuted(let isMuted):
      updateVolume()
    case .isPaused(let isPaused):
      isPaused ? playerNode?.pause() : playerNode?.play()
    case .sampleChanged(let newSample):
      rescheduleSegments()
    case .loudnessChanged(let newLoudness):
      updateVolume()
    case .silenceLengthChanged(let newSilenceLength):
      rescheduleSegments()
    }
  }

  private func rescheduleSegments() {
    guard let playerNode else { return }

    playerNode.stop()

    Task {
      _ = await channel.reschedule(
        audioEngine: audioEngine,
        audioNode: playerNode,
        totalDuraton: 600.seconds
      )

      playerNode.play()
    }
  }

  private func updateVolume() {
    playerNode?.volume = channel.isMuted ? 0.1 : Float(channel.segment.loudness) / 100
  }
}

// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class MelodyGenerator {

  let audioSession = AVAudioSession.sharedInstance()
  let audioEngine = AVAudioEngine()

  var state: MelodyGeneratorState

  private let disposeBag = DisposeBag()

  init(segments: [AudioSegment]) {
    state = .init(
      channels: segments.map { AudioChannel(segment: $0) }
    )

    setupAudioEngine()
    listenForAudioRouteChanges()
  }

  var playerNodes: [AVAudioPlayerNode] = []

  func play(totalDuration: Duration,
            saveToFile fileName: String? = nil) async {
    self.playerNodes = await state.channels.asyncMap {
      await $0.asAudioNode(
        audioEngine: audioEngine,
        totalDuraton: totalDuration
      )
    }

    audioEngine.prepare()

    try! audioEngine.start()

    fileName.map(setupFileSaving)

    synchronizeChannelsAndStartPlaying()

    DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration.asTimeInterval + 1) { [weak self] in
      self?.playerNodes.forEach { $0.stop() }
      self?.audioEngine.mainMixerNode.removeTap(onBus: 0)
    }
  }

  private func synchronizeChannelsAndStartPlaying() {
    playerNodes.forEach { $0.prepare(withFrameCount: 8192) }

    let hostTimeNow = mach_absolute_time()
    let hostTimeFuture = hostTimeNow + AVAudioTime.hostTime(forSeconds: 0.25);

    // Небольшая задержка, чтобы все каналы начали играть строго одновременно.
    let startTime = AVAudioTime(hostTime: hostTimeFuture)

    playerNodes.forEach { $0.play(at: startTime) }
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

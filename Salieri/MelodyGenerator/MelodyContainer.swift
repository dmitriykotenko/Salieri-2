// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class MelodyContainer {

  var channels: [AudioChannel]
  var isPlaying: Bool = false { didSet { stateUpdated.onNext(()) } }
  var isRecoring: Bool = false { didSet { stateUpdated.onNext(()) } }

  var isMicMuted: Bool = true {
    didSet { micEvents.onNext(isMicMuted) }
  }

  var channelEvents = PublishSubject<AudioChannelEvent>()
  var micEvents = PublishSubject<Bool>()

  var stateUpdated = PublishSubject<Void>()

  init(channels: [AudioChannel] = []) {
    self.channels = channels
  }

  func prepareToDemonstrate(channel: AudioChannel) {
    channels.filter { $0.id != channel.id }.forEach {
      process(
        event: .channelChange(
          .isPaused(
            channel: $0,
            isPaused: true
          )
        ),
        shouldPropagate: false
      )
    }
  }

  func prepareToPlay(isRecording: Bool) {
    isPlaying = true
    self.isRecoring = isRecording

    channels.forEach {
      process(event: .channelChange(.isPaused(channel: $0, isPaused: $0.isMuted)))
    }
  }

  func prepareToStop() {
    channels.forEach {
      process(event: .channelChange(.isPaused(channel: $0, isPaused: true)))
    }
    
    isPlaying = false
    isRecoring = false
  }

  func process(event: MelodyEvent,
               shouldPropagate: Bool = true) {
    switch event {
    case .channelChange(let channelEvent):
      channels = channels.map {
        $0.id == channelEvent.initialChannel.id ? channelEvent.apply(to: $0) : $0
      }
      if shouldPropagate {
        channelEvents.onNext(channelEvent)
      }
    case .channelAdded(let audioChannel):
      guard !isPlaying else { return }
      channels += [audioChannel]
    case .channelDeleted(let channedId):
      guard !isPlaying else { return }
      channels = channels.filter { $0.id != channedId }
    }
  }
}

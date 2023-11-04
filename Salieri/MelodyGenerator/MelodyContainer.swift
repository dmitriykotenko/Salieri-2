// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class MelodyContainer {

  var channels: [AudioChannel]
  var isPlaying: Bool = false

  var channelEvents = PublishSubject<AudioChannelEvent>()

  init(channels: [AudioChannel] = []) {
    self.channels = channels
  }

  func process(event: MelodyEvent) {
    switch event {
    case .channelChange(let channelEvent):
      channels = channels.map {
        $0.id == channelEvent.initialChannel.id ? channelEvent.apply(to: $0) : $0
      }
      channelEvents.onNext(channelEvent)
    case .channelAdded(let audioChannel):
      guard !isPlaying else { return }
      channels += [audioChannel]
    case .channelDeleted(let channedId):
      guard !isPlaying else { return }
      channels = channels.filter { $0.id != channedId }
    }
  }
}

// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


enum AudioChannelEvent: Equatable, Hashable, Codable {

  case isMuted(channel: AudioChannel, isMuted: Bool)
  case isPaused(channel: AudioChannel, isPaused: Bool)

  case sampleChanged(channel: AudioChannel, newSample: AudioSample)
  case loudnessChanged(channel: AudioChannel, newLoudness: Int)
  case silenceLengthChanged(channel: AudioChannel, newSilenceLength: CGFloat)

  var initialChannel: AudioChannel {
    switch self {
    case .isMuted(let channel, _):
      return channel
    case .isPaused(let channel, _):
      return channel
    case .sampleChanged(let channel, _):
      return channel
    case .loudnessChanged(let channel, _):
      return channel
    case .silenceLengthChanged(let channel, _):
      return channel
    }
  }

  var isReschedulingNeeded: Bool {
    switch self {
    case .isMuted, .isPaused, .loudnessChanged:
      return false
    case .sampleChanged, .silenceLengthChanged:
      return true
    }
  }

  func apply(to channel: AudioChannel) -> AudioChannel {
    switch self {
    case .isMuted(_, let isMuted):
      return channel.with(\.isMuted, isMuted)
    case .isPaused(_, let isPaused):
      return channel.with(\.isPaused, isPaused)
    case .sampleChanged(_, let newSample):
      return channel.with(\.segment.sample, newSample)
    case .loudnessChanged(_, let newLoudness):
      return channel.with(\.segment.loudness, newLoudness)
    case .silenceLengthChanged(_, let newSilenceLength):
      return channel.with(\.segment.silenceLength, newSilenceLength)
    }
  }
}

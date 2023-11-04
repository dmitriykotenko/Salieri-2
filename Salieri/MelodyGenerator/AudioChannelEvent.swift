// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


enum AudioChannelEvent: Equatable, Hashable, Codable {

  case isMuted(Bool)
  case isPaused(Bool)

  case sampleChanged(AudioSample)
  case loudnessChanged(Int)
  case silenceLengthChanged(CGFloat)

  func apply(to channel: AudioChannel) -> AudioChannel {
    switch self {
    case .isMuted(let isMuted):
      return channel.with(\.isMuted, isMuted)
    case .isPaused(let isPaused):
      return channel.with(\.isPaused, isPaused)
    case .sampleChanged(let newSample):
      return channel.with(\.segment.sample, newSample)
    case .loudnessChanged(let newLoudness):
      return channel.with(\.segment.loudness, newLoudness)
    case .silenceLengthChanged(let newSilenceLength):
      return channel.with(\.segment.silenceLength, newSilenceLength)
    }
  }
}

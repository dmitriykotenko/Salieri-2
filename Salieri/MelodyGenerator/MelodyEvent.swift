// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


enum MelodyEvent: Equatable, Hashable, Codable {

  case channelChange(AudioChannelEvent)
  case channelAdded(AudioChannel)
  case channelDeleted(id: UUID)
}

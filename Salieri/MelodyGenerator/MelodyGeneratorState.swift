// @ Dmitry Kotenko

import Foundation


struct MelodyGeneratorState: Equatable, Hashable, Codable {

  var scheduleLength: Duration = 60.seconds
  var channels: [AudioChannel]
  var isMicMuted: Bool = true

  var isPlayingMelody: Bool = false
  var baseTime: Duration
  var scheduleEndTime: Duration?
}

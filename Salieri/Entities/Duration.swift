// @ Dmitry Kotenko

import Foundation


struct Duration: Equatable, Hashable, Codable, Comparable {

  var milliseconds: Int

  var asTimeInterval: TimeInterval {
    .init(TimeInterval(milliseconds) / 1000)
  }

  var negated: Duration {
    .init(milliseconds: -milliseconds)
  }

  static let zero = 0.milliseconds

  static func + (this: Duration, that: Duration) -> Duration {
    .init(milliseconds: this.milliseconds + that.milliseconds)
  }

  static func - (this: Duration, that: Duration) -> Duration {
    .init(milliseconds: this.milliseconds - that.milliseconds)
  }

  static func * (duration: Duration, multiplier: CGFloat) -> Duration {
    .init(milliseconds: Int(CGFloat(duration.milliseconds) * multiplier))
  }

  static func * (duration: Duration, multiplier: Int) -> Duration {
    .init(milliseconds: duration.milliseconds * multiplier)
  }

  static func % (this: Duration, that: Duration) -> Duration {
    .init(milliseconds: this.milliseconds % that.milliseconds)
  }

  static func < (this: Duration, that: Duration) -> Bool {
    this.milliseconds < that.milliseconds
  }
}


extension Int {

  var milliseconds: Duration { .init(milliseconds: self) }
  var seconds: Duration { .init(milliseconds: self * 1000) }
}

// @ Dmitry Kotenko

import Foundation


struct AudioSegment: Equatable, Hashable, Codable {

  var sample: AudioSample

  /// Громкость (от 0 до 100).
  var loudness: Int = 100

  /// Пауза между повторениями сэмпла (от 0x до 1000x).
  /// 1x означает паузу, равную длине сэмпла.
  var silenceLength: CGFloat = 0

  static func unrepeatable(sample: AudioSample) -> AudioSegment {
    .init(
      sample: sample,
      silenceLength: 10_000_000_000
    )
  }

  func durationUntilSampleEnd(from duration: Duration) -> Duration {
    let relativeDuration = duration % period
    return max(sample.duration - relativeDuration, .zero)
  }

  func shouldBeSilent(at duration: Duration) -> Bool {
    duration % period >= sample.duration
  }

  var period: Duration {
    sample.duration + silenceDuration
  }

  var silenceDuration: Duration {
    Int(CGFloat(sample.duration.milliseconds) * silenceLength).milliseconds
  }
}

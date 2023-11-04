// @ Dmitry Kotenko

import Foundation


struct AudioSegment: Equatable, Hashable, Codable {

  var sample: AudioSample

  /// Громкость (от 0 до 100).
  var loudness: Int

  /// Пауза между повторениями сэмпла (от 0x до 1000x).
  /// 1x означает паузу, равную длине сэмпла.
  var silenceLength: CGFloat

  var period: Duration {
    sample.duration + silenceDuration
  }

  var silenceDuration: Duration {
    Int(CGFloat(sample.duration.milliseconds) * silenceLength).milliseconds
  }
}

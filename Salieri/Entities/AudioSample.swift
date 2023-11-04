// @ Dmitry Kotenko

import AVFoundation
import Foundation


struct AudioSample: Equatable, Hashable, Codable {

  var instrumentKind: MusicalInstrumentKind
  var name: String
  var fileName: String

  var duration: Duration

  init(instrumentKind: MusicalInstrumentKind,
       name: String,
       fileName: String) {
    self.instrumentKind = instrumentKind
    self.name = name
    self.fileName = fileName

    let audioUrl = URL.from(resourceFileName: fileName)!
    let audioFile = try! AVAudioFile(forReading: audioUrl)
    
    self.duration = audioFile.duration
  }

  static let cMinBass = AudioSample(
    instrumentKind: .guitar,
    name: "c-min-bass",
    fileName: "c-min-bass.wav"
  )

  static let eMinSwellingPad = AudioSample(
    instrumentKind: .guitar,
    name: "e-min-swelling-pad",
    fileName: "e-min-swelling-pad.wav"
  )

  static let d80811 = AudioSample(
    instrumentKind: .drum,
    name: "808-11-d",
    fileName: "808-11-d.wav"
  )
}

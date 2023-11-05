// @ Dmitry Kotenko

import AVFoundation
import Foundation


struct AudioSample: Equatable, Hashable, Codable, Buildable {

  enum FileName: Equatable, Hashable, Codable {
    case resource(String)
    case recorded(URL)
  }

  var instrumentKind: MusicalInstrumentKind
  var name: String
  var shortName: String
  var summary: String?
  var fileName: FileName

  var duration: Duration

  var canBeRepeated: Bool { instrumentKind != .mic }

  init(instrumentKind: MusicalInstrumentKind,
       name: String,
       shortName: String,
       summary: String?,
       fileName: FileName) {
    self.instrumentKind = instrumentKind
    self.name = name
    self.shortName = shortName
    self.fileName = fileName

    let audioUrl = URL.from(audioSampleFileName: fileName)!
    let audioFile = try! AVAudioFile(forReading: audioUrl)
    
    self.duration = audioFile.duration
  }

  static let guitar1 = cMinBass.with(\.name, "Гитара 1").with(\.shortName, "Сэмпл 1")
  static let guitar2 = eMinSwellingPad.with(\.name, "Гитара 2").with(\.shortName, "Сэмпл 2")
  static let guitar3 = d80811.with(\.name, "Гитара 3").with(\.shortName, "Сэмпл 3")

  static let drum1 = cMinBass.with(\.name, "Ударные 1").with(\.shortName, "Сэмпл 1")
  static let drum2 = eMinSwellingPad.with(\.name, "Ударные 2").with(\.shortName, "Сэмпл 2")
  static let drum3 = d80811.with(\.name, "Ударные 3").with(\.shortName, "Сэмпл 3")

  static let wind1 = cMinBass.with(\.name, "Духовые 1").with(\.shortName, "Сэмпл 1")
  static let wind2 = eMinSwellingPad.with(\.name, "Духовые 2").with(\.shortName, "Сэмпл 2")
  static let wind3 = d80811.with(\.name, "Духовые 3").with(\.shortName, "Сэмпл 3")

  static let cMinBass = AudioSample(
    instrumentKind: .guitar,
    name: "c-min-bass",
    shortName: "c-min-bass",
    summary: "c-min-bass",
    fileName: .resource("c-min-bass.wav")
  )

  static let eMinSwellingPad = AudioSample(
    instrumentKind: .guitar,
    name: "e-min-swelling-pad",
    shortName: "e-min-swelling-pad",
    summary: "e-min-swelling-pad",
    fileName: .resource("e-min-swelling-pad.wav")
  )

  static let d80811 = AudioSample(
    instrumentKind: .drum,
    name: "808-11-d",
    shortName: "808-11-d",
    summary: "808-11-d",
    fileName: .resource("808-11-d.wav")
  )

  static let mic1 = AudioSample(
    instrumentKind: .mic,
    name: "mic-1",
    shortName: "mic-1",
    summary: nil,
    fileName: .resource("808-11-d.wav")
  )
}

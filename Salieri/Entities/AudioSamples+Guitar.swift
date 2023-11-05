// @ Dmitry Kotenko

import AVFoundation
import Foundation


extension AudioSample {

  static let guitarSamples: [Self] = [
    .init(
      instrumentKind: .guitar,
      name: "Гитара 1",
      shortName: "Сэмпл 1",
      summary: "Chord-Loop---100-BPM-F-Min",
      fileName: .resource("GG-Funk-Chord-Loop-7---100-BPM-F-Min.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 2",
      shortName: "Сэмпл 2",
      summary: "Guitar-Loop---100-BPM-F-Maj",
      fileName: .resource("Moonlight-Guitar-Loop-3---100-BPM-F-Maj.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 3",
      shortName: "Сэмпл 3",
      summary: "Guitar-Loop---110-BPM-G#-Maj",
      fileName: .resource("Moonlight-Guitar-Loop-7---110-BPM-G#-Maj.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 4",
      shortName: "Сэмпл 4",
      summary: "Guitar-Loop---110-BPM-A-Maj",
      fileName: .resource("Moonlight-Guitar-Loop-8---110-BPM-A-Maj.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 5",
      shortName: "Сэмпл 5",
      summary: "Guitar-Loop---110-BPM-A-Min",
      fileName: .resource("Moonlight-Guitar-Loop-10---110-BPM-A-Min.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 6",
      shortName: "Сэмпл 6",
      summary: "Chord-Loop---140-BPM-D#-Min",
      fileName: .resource("Titan-Guitar-Chord-Loop-4---140-BPM-D#-Min.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 7",
      shortName: "Сэмпл 7",
      summary: "Chord-Loop---140-BPM-F#-Min",
      fileName: .resource("Titan-Guitar-Chord-Loop-8---140-BPM-F#-Min.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 8",
      shortName: "Сэмпл 8",
      summary: "Chord-Loop---160-BPM-D#-Maj",
      fileName: .resource("Titan-Guitar-Chord-Loop-11---160-BPM-D#-Maj.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 9",
      shortName: "Сэмпл 9",
      summary: "Melody-Loop---160-BPM-D-Maj",
      fileName: .resource("Titan-Guitar-Melody-Loop-9---160-BPM-D-Maj.wav")
    ),
    .init(
      instrumentKind: .guitar,
      name: "Гитара 10",
      shortName: "Сэмпл 10",
      summary: "Melody-Loop---160-BPM-D#-Min",
      fileName: .resource("Titan-Guitar-Melody-Loop-11---160-BPM-D#-Min.wav")
    )
  ]
}

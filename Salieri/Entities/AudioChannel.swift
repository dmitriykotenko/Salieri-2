// @ Dmitry Kotenko

import AVFoundation
import Foundation


struct AudioChannel: Equatable, Hashable, Codable, Buildable {

  let id: UUID
  var segment: AudioSegment

  var isMuted: Bool
  var isPaused: Bool
  var baseTime: Duration
  var offset: Duration

  init(id: UUID = UUID(),
       segment: AudioSegment,
       isMuted: Bool = false,
       isPaused: Bool = false,
       baseTime: Duration = .zero,
       offset: Duration = .zero) {
    self.id = id
    self.segment = segment
    self.isMuted = isMuted
    self.isPaused = isPaused
    self.baseTime = baseTime
    self.offset = offset
  }

  func asAudioNode(audioEngine: AVAudioEngine,
                   totalDuraton: Duration) async -> AVAudioPlayerNode {
    let fileUrl = URL.from(audioSampleFileName: segment.sample.fileName)!

    let audioFile = try! AVAudioFile(forReading: fileUrl)

    let node = AVAudioPlayerNode()
    node.volume = Float(segment.loudness) / 100.0

    audioEngine.attach(node)
    audioEngine.connect(node, to: audioEngine.mainMixerNode, format: nil)

    var startDuration: Duration = .zero

    while startDuration <= totalDuraton {
      print("schedule-file---\(startDuration.milliseconds)")
      node.scheduleFile(audioFile, offset: startDuration, completionHandler: nil)
      startDuration = startDuration + segment.period
    }

    return node
  }

  func reschedule(audioEngine: AVAudioEngine,
                  audioNode: AVAudioPlayerNode,
                  totalDuraton: Duration,
                  offset: Duration = .zero) async -> AVAudioPlayerNode {
    let fileUrl = URL.from(audioSampleFileName: segment.sample.fileName)!

    let audioFile = try! AVAudioFile(forReading: fileUrl)

    audioNode.volume = Float(segment.loudness) / 100.0

    var startDuration: Duration = offset

    while startDuration <= totalDuraton {
      if startDuration < .zero && startDuration + audioFile.duration > .zero {
        audioNode.scheduleFile(
          audioFile,
          fileStart: startDuration.negated,
          fileEnd: audioFile.duration,
          offset: .zero,
          completionHandler: nil
        )
      } else {
        audioNode.scheduleFile(audioFile, offset: startDuration, completionHandler: nil)
      }

      startDuration = startDuration + segment.period
    }

    return audioNode
  }

//  func scheduleWithOffset(_ offset: TimeInterval,
//                          file1: AVAudioFile,
//                          file2: AVAudioFile,
//                          player1: AVAudioPlayerNode,
//                          player2: AVAudioPlayerNode) async {
//    let sampleRate1 = file1.processingFormat.sampleRate
//
//    await player1.scheduleSegment(
//      file1,
//      startingFrame: 0,
//      frameCount: AVAudioFrameCount(file1.length),
//      at: AVAudioTime(sampleTime: 0, atRate: sampleRate1)
//    )
//
//    let sampleRate2 = file2.processingFormat.sampleRate
//    await player2.scheduleSegment(
//      file2,
//      startingFrame: 0,
//      frameCount: AVAudioFrameCount(file2.length),
//      at: AVAudioTime(
//        sampleTime: AVAudioFramePosition(offset * sampleRate2),
//        atRate: sampleRate2
//      )
//    )
//
//    //This can take an indeterminate amount of time, so both files should be prepared before either starts.
//    player1.prepare(withFrameCount: 8192)
//    player2.prepare(withFrameCount: 8192)
//
//    // Start the files at common time slightly in the future to ensure a synchronous start.
//    let hostTimeNow = mach_absolute_time()
//    let hostTimeFuture = hostTimeNow + AVAudioTime.hostTime(forSeconds: 0.2);
//    let startTime = AVAudioTime(hostTime: hostTimeFuture)
//
//    player1.play(at: startTime)
//    player2.play(at: startTime)
//  }
}


extension AVAudioPlayerNode {

  func scheduleFile(_ file: AVAudioFile,
                    offset: Duration) async {
//    await scheduleFile(file, at: nil)
    let sampleRate = file.processingFormat.sampleRate

    await scheduleSegment(
      file,
      startingFrame: 0,
      frameCount: AVAudioFrameCount(file.length),
      at: AVAudioTime(
        sampleTime: AVAudioFramePosition(offset.asTimeInterval * sampleRate),
        atRate: sampleRate
      )
    )
  }

  func scheduleFileV1(_ file: AVAudioFile,
                      offset: Duration,
                      completionHandler: AVAudioNodeCompletionHandler? = nil) {
    //    await scheduleFile(file, at: nil)
    let sampleRate = file.processingFormat.sampleRate

    scheduleSegment(
      file,
      startingFrame: 0,
      frameCount: AVAudioFrameCount(file.length),
      at: AVAudioTime(
        sampleTime: AVAudioFramePosition(offset.asTimeInterval * sampleRate),
        atRate: sampleRate
      ),
      completionHandler: completionHandler
    )
  }

  func scheduleFile(_ file: AVAudioFile,
                    fileStart: Duration = .zero,
                    fileEnd: Duration? = nil,
                    offset: Duration,
                    completionHandler: AVAudioNodeCompletionHandler? = nil) {
    //    await scheduleFile(file, at: nil)
    let sampleRate = file.processingFormat.sampleRate
    let startingFrame = AVAudioFramePosition(fileStart.asTimeInterval * sampleRate)

    let frameCount = AVAudioFrameCount(
      ((fileEnd ?? file.duration) - fileStart).asTimeInterval * sampleRate
    ).clamped(
      inside: 0...AVAudioFrameCount(file.length)
    )

    scheduleSegment(
      file,
      startingFrame: startingFrame,
      frameCount: frameCount,
      at: AVAudioTime(
        sampleTime: AVAudioFramePosition(offset.asTimeInterval * sampleRate),
        atRate: sampleRate
      ),
      completionHandler: completionHandler
    )
  }
}


extension AVAudioFile {

  var duration: Duration {
    Int(Double(length) * 1000 / processingFormat.sampleRate).milliseconds
  }
}


extension AVAudioTime {

  var asTimeInterval: TimeInterval {
    Double(sampleTime) / sampleRate
  }

  var asDuration: Duration {
    Int(asTimeInterval * 1000).milliseconds
  }
}

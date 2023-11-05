// @ Dmitry Kotenko

import Accelerate
import AVFoundation
import Foundation
import RxSwift
import UIKit


class PcmBufferParser {

  var prevRMSValue : Float = 0.3

  func processAudioData(buffer: AVAudioPCMBuffer) -> [Float] {
    guard let channelData = buffer.floatChannelData?[0] else { return [] }
    let frames = buffer.frameLength

    let rmsValue = Self.rms(data: channelData, frameLength: UInt(frames))
    let interpolatedResults = Self.interpolate(current: rmsValue, previous: prevRMSValue)
    prevRMSValue = rmsValue

    return interpolatedResults
  }

  func processChunkedAudioData(buffer: AVAudioPCMBuffer) -> [Float] {
    guard let channelData = buffer.floatChannelData?[0] else { return [] }
    let frames = buffer.frameLength

    let rmsValues = Self.chunkedRms(data: channelData, frameLength: UInt(frames), chunksCount: 10)
//
//    let interpolatedResults = Self.interpolate(current: rmsValue, previous: prevRMSValue)
//    prevRMSValue = rmsValue

    return rmsValues
  }

  static func chunkedRms(data: UnsafeMutablePointer<Float>,
                         frameLength: UInt,
                         chunksCount: UInt) -> [Float] {
    var result: [Float] = []

    let chunkSize = frameLength / chunksCount

    (0..<chunksCount).forEach {
      result.append(rms(data: data + Int($0 * chunkSize), frameLength: chunkSize))
    }

    return result
  }

  static func rms(data: UnsafeMutablePointer<Float>,
                  frameLength: UInt) -> Float {
    var val : Float = 0
    vDSP_measqv(data, 1, &val, frameLength)
    var db = 10*log10f(val)
    //inverse dB to +ve range where 0(silent) -> 160(loudest)
    db = 160 + db;
    //Only take into account range from 120->160, so FSR = 40
    db = db - 120
    let dividor = Float(40/0.3)
    var adjustedVal = 0.3 + db/dividor

    //cutoff
    if (adjustedVal < 0.3) {
      adjustedVal = 0.3
    } else if (adjustedVal > 0.6) {
      adjustedVal = 0.6
    }

    return adjustedVal
  }

  static func interpolate(current: Float, previous: Float) -> [Float]{
    var vals = [Float](repeating: 0, count: 11)
    vals[10] = current
    vals[5] = (current + previous)/2
    vals[2] = (vals[5] + previous)/2
    vals[1] = (vals[2] + previous)/2
    vals[8] = (vals[5] + current)/2
    vals[9] = (vals[10] + current)/2
    vals[7] = (vals[5] + vals[9])/2
    vals[6] = (vals[5] + vals[7])/2
    vals[3] = (vals[1] + vals[5])/2
    vals[4] = (vals[3] + vals[5])/2
    vals[0] = (previous + vals[1])/2

    return vals
  }}

// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class SoundVisualisationView: View {

  func reset() {
    frames = []
    currentDuration = .zero
  }

  func add(rawFrames: [Float],
           rawFrameRate: Int,
           setCurrentDuration newDuration: Duration) {
//    frames += beautify(
//      rawFrames: rawFrames,
//      rawFrameRate: rawFrameRate
//    )

    print("sound-visualization---raw-frames---")
    print(rawFrames)

    frames += rawFrames.map { CGFloat($0) }

    currentDuration = newDuration

    DispatchQueue.main.async { [weak self] in
      self?.setNeedsDisplay()
    }
  }
//
//  private func beautify(rawFrames: [Float],
//                        rawFrameRate: Int) -> [CGFloat] {
//    let chunkSize = rawFrameRate / sampleRate
//
//    let chunks = rawFrames.map { abs($0) }.chunks(length: chunkSize)
//
//    return chunks.flatMap {
//      $0.reduce(CGFloat(0), +) / CGFloat($0.count)
//    }
//  }

  var frames: [CGFloat] = []

  var sampleRate: Int = 100
  var currentDuration: Duration = 4.seconds

  var strokeColor: UIColor = .melodyVisualisationStroke
  var strokeWidth: CGFloat = 2
  var shadowColor: UIColor = .melodyVisualisationStroke
  let finalCircleRadius: CGFloat = 4

  let durationThresholds = (0...20).map { Int(pow(2, Float($0))).seconds }

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    print("sound-visualisation---frames-count---\(frames.count)")
    print("sound-visualisation---duration---\(currentDuration)")

    guard let context = UIGraphicsGetCurrentContext() else { return }

    let points = lineToDraw(inRect: rect)
    guard !points.isEmpty else { return }

    context.setLineWidth(strokeWidth)
    context.setStrokeColor(strokeColor.cgColor)
    context.setLineCap(.round)
    context.setLineJoin(.round)

    context.move(to: points[0])
    points.dropFirst().forEach { context.addLine(to: $0) }
    context.strokePath()

    if let finalCircleCenter = points.last {
      context.setShadow(offset: .zero, blur: 20, color: shadowColor.cgColor)
      context.setFillColor(strokeColor.withAlphaComponent(0.25).cgColor)
      let radius2 = finalCircleRadius * 3

      context.addEllipse(
        in: .init(
          x: finalCircleCenter.x - radius2,
          y: finalCircleCenter.y - radius2,
          width: 2 * radius2,
          height: 2 * radius2
        )
      )
      context.fillPath()

      context.setShadow(offset: .zero, blur: 10, color: shadowColor.cgColor)
      context.setFillColor(strokeColor.withAlphaComponent(1).cgColor)
      context.setAlpha(1)
      let radius = finalCircleRadius

      context.addEllipse(
        in: .init(
          x: finalCircleCenter.x - radius,
          y: finalCircleCenter.y - radius,
          width: 2 * radius,
          height: 2 * radius
        )
      )

      context.fillPath()
    }
  }

  private func lineToDraw(inRect rect: CGRect) -> [CGPoint] {
    let safeRect = rect.insetBy(dx: 3 * finalCircleRadius, dy: 3 * finalCircleRadius)

    let loudnessBounds = CGFloat(0.28)...CGFloat(0.65)

    let normalizedLoudnesses = frames.map {
      abs($0).normalizedInside(bounds: loudnessBounds) * CGFloat(sign($0))
    }

    let loudnesses = normalizedLoudnesses.map {
      $0.normalizedInside(bounds: 0...1)
    }

    let durationBounds =
      max(currentDuration - 9.seconds, .zero)...max(currentDuration + 1.seconds, 10.seconds)
    
    let durationBoundsLength = durationBounds.upperBound - durationBounds.lowerBound

    let xFromDuration = { (duration: Duration) in
      let offsetFromStart = (duration - durationBounds.lowerBound)
      let portion = CGFloat(offsetFromStart.milliseconds) / CGFloat(durationBoundsLength.milliseconds)

      return safeRect.origin.x + portion * safeRect.width
    }

    let durationFromFrameIndex = { (frameIndex: Int) in
      (frameIndex * 1000 / self.sampleRate).milliseconds
    }

    let xFromFrameIndex = { (frameIndex: Int) in
      xFromDuration(durationFromFrameIndex(frameIndex))
    }

    let yFromLoudness = { (loudness: CGFloat) in
      safeRect.maxY - loudness * safeRect.height
    }

    let points = loudnesses.enumerated().map { index, loudness in
      CGPoint(x: xFromFrameIndex(index), y: yFromLoudness(loudness))
    }

    return points
  }
}


extension CGFloat {

  func normalizedInside(bounds: ClosedRange<CGFloat>) -> CGFloat {
    (self - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
  }
}

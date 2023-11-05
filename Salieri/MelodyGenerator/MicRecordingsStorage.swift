// @ Dmitry Kotenko

import AVFoundation
import Foundation
import RxSwift


class MicRecordingsStorage {

  struct MicRecordingSpec {
    var name: String
    var shortName: String
    var fileName: String
  }

  var nextRecordingSpec: MicRecordingSpec {
    currentIndex += 1

    return .init(
      name: "Сэмпл \(currentIndex)",
      shortName: "Микрофон \(currentIndex)",
      fileName: micRecordingFileName(index: currentIndex)
    )
  }

  private let fileManager = FileManager.default

  private lazy var folder = fileManager.micRecordingsFolder

  private var currentIndex: Int = 0

  init(currentIndex: Int = 0) {
    self.currentIndex = currentIndex

    recreateFolder()
  }

  private func recreateFolder() {
    if let folder {
      try? fileManager.removeItem(at: folder)
      try? fileManager.createDirectory(
        at: folder,
        withIntermediateDirectories: false
      )
    }
  }

  private func micRecordingFileName(index: Int) -> String {
    let fileName = "mic-recording-\(index).wav"

    return folder?.lastPathComponent.appending("/" + fileName) ?? fileName
  }
}

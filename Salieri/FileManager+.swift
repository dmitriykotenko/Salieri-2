// @ Dmitry Kotenko

import AVFoundation
import Foundation


extension FileManager {

  var documentsFolder: URL? {
    urls(for: .documentDirectory, in: .userDomainMask).first
  }

  var micRecordingsFolder: URL? {
    documentsFolder?.appending(component: "mic-recordings")
  }

  func fileUrl(fileName: String,
               parentFolder: URL?) -> URL? {
    parentFolder?.appendingPathComponent(fileName)
  }

  func fileUrl(fileName: String) -> URL? {
    fileUrl(fileName: fileName, parentFolder: documentsFolder)
  }

  func removeFile(name: String) throws {
    try removeFile(name: name, parentFolder: documentsFolder)
  }

  func removeFile(name: String,
                  parentFolder: URL?) throws {
    if let url = fileUrl(fileName: name, parentFolder: parentFolder) {
      try removeItem(at: url)
    }
  }
}

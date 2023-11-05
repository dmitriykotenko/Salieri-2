// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension URL {

  static func from(audioSampleFileName: AudioSample.FileName) -> URL? {
    switch audioSampleFileName {
    case .resource(let resourceFileName):
      return from(resourceFileName: resourceFileName)
    case .recorded(let fileUrl):
      return fileUrl
    }
  }

  static func from(resourceFileName: String) -> URL? {
    guard let (fileName, fileExtension) = resourceFileName.fileNameAndExtension
    else { return nil }

    let filePath = Bundle.main.path(forResource: fileName, ofType: fileExtension)
    return filePath.map { URL(filePath: $0) }
  }
}


extension String {

  var fileNameAndExtension: (fileName: String, fileExtension: String)? {
    let components = split(separator: ".")
    guard components.count == 2 else { return nil }
    return (String(components[0]), String(components[1]))
  }
}

// @ Dmitry Kotenko

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit


extension URL {

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

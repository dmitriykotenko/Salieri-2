// @ Dmitry Kotenko

import Foundation
import UIKit


class MelodySharer {

  weak var parentViewController: UIViewController?

  init(parentViewController: UIViewController? = nil) {
    self.parentViewController = parentViewController
  }

  func shareMelody(fileName: String) {
    shareMelodyViaUiActivityViewController(fileName: fileName)
  }

  private func shareMelodyViaUiActivityViewController(fileName: String) {
    if let fileToShare = FileManager.default.fileUrl(fileName: fileName) {
      let objectsToShare: [Any] = [fileToShare]

      let sharingMenu = UIActivityViewController(
        activityItems: objectsToShare,
        applicationActivities: nil
      )

      parentViewController?.present(
        sharingMenu,
        animated: true,
        completion: nil
      )
    }
  }

  private func shareMelodyViaDocumentInteractionController(fileName: String) {
    if let fileToShare = FileManager.default.fileUrl(fileName: fileName) {
      let controller = UIDocumentInteractionController(url: fileToShare)

      controller.presentOpenInMenu(
        from: CGRect.zero,
        in: parentViewController!.view,
        animated: true
      )
    }
  }
}

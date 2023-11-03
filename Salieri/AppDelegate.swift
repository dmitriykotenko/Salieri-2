// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var viewController: ViewController?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    setupUi()
    return true
  }

  private func setupUi() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let viewController = ViewController()

    window.rootViewController = viewController
    window.makeKeyAndVisible()

    self.window = window
    self.viewController = viewController
  }
}


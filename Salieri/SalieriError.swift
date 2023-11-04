// @ Dmitry Kotenko

import Foundation


enum SalieriError: Error, Equatable, Hashable, Codable {

  case plain(reason: String)
}

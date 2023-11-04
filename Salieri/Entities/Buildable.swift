// @ Dmitry Kotenko

import AVFoundation
import Foundation

protocol Buildable {}

extension Buildable {

  func with<Property>(_ keyPath: WritableKeyPath<Self, Property>,
                      _ propertyValue: Property) -> Self {
    var result = self
    result[keyPath: keyPath] = propertyValue
    return result
  }

  func with<Property>(_ keyPath: WritableKeyPath<Self, Property>,
                      _ transform: (Property) -> Property) -> Self {
    var result = self
    result[keyPath: keyPath] = transform(result[keyPath: keyPath])
    return result
  }
}

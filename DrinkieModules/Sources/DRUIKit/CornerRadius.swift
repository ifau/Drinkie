import Foundation
import UIKit

public enum CornerRadius {
    
    case none
    case small
    case medium
    case large
    case extraLarge
    
    public var value: CGFloat {
        switch self {
        case .none:  return 0.0
        case .small: return 8.0
        case .medium: return 16.0
        case .large: return 24.0
        case .extraLarge: return 32.0
        }
    }
}


public extension UIView {
    func roundCorners(by radius: CGFloat, corners: CACornerMask = .all) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }
}

public extension CACornerMask {
    static let all: CACornerMask = [
        .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner
    ]
}

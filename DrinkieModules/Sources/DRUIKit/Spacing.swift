import Foundation

public enum Spacing {
    case none
    case small
    case medium
    case large
    case extraLarge
    
    public var value: CGFloat {
        switch self {
        case .none:   return 0.0
        case .small:  return 8.0
        case .medium: return 16.0
        case .large:  return 24.0
        case .extraLarge: return 32.0
        }
    }
}

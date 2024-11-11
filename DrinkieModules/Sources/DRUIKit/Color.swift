import Foundation
import UIKit
import SwiftUI

public enum AppColor {
    case brandPrimary
    case brandSecondary
    case brandTertiary
    
    case textPrimary
    case textSecondary
    
    case backgoundPrimary
    case backgroundSecondary
    
    public var value: UIColor {
        switch self {
        case .brandPrimary:
            return UIColor(red: 50.0/255.0, green: 77.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            
        case .brandSecondary:
            return UIColor(red: 50.0/255.0, green: 150/255.0, blue: 244.0/255.0, alpha: 1.0)
            
        case .brandTertiary:
            return UIColor(red: 192.0/255.0, green: 220.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            
        case .textPrimary:
            return UIColor(light: .init(red: 0, green: 0, blue: 0, alpha: 1.0),
                           dark: .init(red: 1, green: 1, blue: 1, alpha: 1.0))
        case .textSecondary:
            return UIColor(light: .init(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0),
                           dark: .init(red: 65.0/255.0, green: 65.0/255.0, blue: 65.0/255.0, alpha: 1.0))
            
        case .backgoundPrimary:
            return UIColor(light: .init(red: 1, green: 1, blue: 1, alpha: 1.0),
                           dark: .init(red: 12.0/255.0, green: 12.0/255.0, blue: 12.0/255.0, alpha: 1.0))
            
        case .backgroundSecondary:
            return UIColor(light: .init(red: 242.0/255.0, green: 247.0/255.0, blue: 249.0/255.0, alpha: 1.0),
                           dark: .init(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 1.0))
        }
    }
}

public extension UIColor {
    convenience init(light lightModeColor: @escaping @autoclosure () -> UIColor, dark darkModeColor: @escaping @autoclosure () -> UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()
            case .dark:
                return darkModeColor()
            case .unspecified:
                return lightModeColor()
            @unknown default:
                return lightModeColor()
            }
        }
    }
}

extension SwiftUI.Color {
    init(light lightModeColor: @escaping @autoclosure () -> SwiftUI.Color, dark darkModeColor: @escaping @autoclosure () -> SwiftUI.Color) {
        self.init(UIColor(light: UIColor(lightModeColor()), dark: UIColor(darkModeColor())))
    }
}

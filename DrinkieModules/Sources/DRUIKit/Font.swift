import Foundation
import UIKit
import CoreGraphics
import CoreText
import SwiftUI

public enum AppFont {
    
    public enum Style: String, CaseIterable {
        case regular = "Stem-Spaced-Regular"
        case italic = "Stem-Spaced-Italic"
        case bold = "Stem-Spaced-Bold"
    }
    
    public static func fixed(_ style: AppFont.Style, size: CGFloat) -> UIFont {
        let font = UIFont(name: style.rawValue, size: size) ?? fallbackFont(style, size: size)
        return font
    }
    
    public static func fixed(_ style: AppFont.Style, size: CGFloat) -> SwiftUI.Font {
        return SwiftUI.Font(fixed(style, size: size))
    }
    
    public static func relative(_ style: AppFont.Style, size: CGFloat, relativeTo textStyle: UIFont.TextStyle) -> UIFont {
        let font = UIFont(name: style.rawValue, size: size) ?? fallbackFont(style, size: size)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
    
    public static func relative(_ style: AppFont.Style, size: CGFloat, relativeTo textStyle: UIFont.TextStyle) -> SwiftUI.Font {
        return SwiftUI.Font(relative(style, size: size, relativeTo: textStyle))
    }
    
    private static func fallbackFont(_ style: AppFont.Style, size: CGFloat) -> UIFont {
        switch style {
        case .regular: return UIFont.systemFont(ofSize: size)
        case .italic: return UIFont.italicSystemFont(ofSize: size)
        case .bold: return UIFont.boldSystemFont(ofSize: size)
        }
    }
}

public func registerFonts() {
    AppFont.Style.allCases.forEach { name in
        guard let asset = NSDataAsset(name: "Fonts/\(name.rawValue)", bundle: Bundle.module),
              let provider = CGDataProvider(data: asset.data as NSData),
              let font = CGFont(provider),
              CTFontManagerRegisterGraphicsFont(font, nil) else {
            fatalError("Failed to register the \(name) font")
        }
    }
}

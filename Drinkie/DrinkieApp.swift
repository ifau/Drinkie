//
//  DrinkieApp.swift
//  Drinkie
//
//  Created by ifau on 05.11.2024.
//

import SwiftUI
import DRUIKit

@main
struct DrinkieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        DRUIKit.registerFonts()
    }
}

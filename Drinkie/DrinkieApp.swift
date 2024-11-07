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
    
    @StateObject var container = ProductionContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencyContainer, container)
        }
    }
    
    init() {
        DRUIKit.registerFonts()
    }
}

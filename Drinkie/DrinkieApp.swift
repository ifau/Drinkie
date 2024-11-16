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
    
    @StateObject var session: Session
    @StateObject var container: DependencyContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(container)
        }
    }
    
    init() {
        DRUIKit.registerFonts()
        
        let newSession = Session()
        let container = PreviewContainer()
        container.registerSingleton(singletonInstance: newSession)
        
        _session = .init(wrappedValue: newSession)
        _container = .init(wrappedValue: container)
    }
}

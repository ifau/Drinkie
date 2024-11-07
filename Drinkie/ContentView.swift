import SwiftUI
import Menu

struct ContentView: View {
    
    @Environment(\.dependencyContainer) var container
    
    var body: some View {
        MenuModule.rootView(dependencies: container.resolve())
    }
}

#Preview {
    ContentView()
}

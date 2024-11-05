import SwiftUI
import Menu

struct ContentView: View {
    var body: some View {
        MenuModule.rootView(dependencies: .init())
    }
}

#Preview {
    ContentView()
}

import SwiftUI

@main
struct MenuBarSpacingApp: App {
    @State private var defaults = SpacingDefaults()

    var body: some Scene {
        WindowGroup {
            ContentView(defaults: defaults)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 580)
    }
}

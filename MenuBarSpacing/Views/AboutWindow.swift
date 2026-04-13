import AppKit
import SwiftUI

@MainActor
enum AboutWindow {
    private static var window: NSWindow?

    static func show() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingView = NSHostingController(rootView: AboutView())
        let newWindow = NSWindow(contentViewController: hostingView)
        newWindow.title = String(localized: "About Menu Bar Spacing")
        newWindow.styleMask = [.titled, .closable]
        newWindow.isReleasedWhenClosed = false
        newWindow.setContentSize(NSSize(width: 480, height: 680))
        newWindow.minSize = NSSize(width: 480, height: 520)
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = newWindow
    }
}

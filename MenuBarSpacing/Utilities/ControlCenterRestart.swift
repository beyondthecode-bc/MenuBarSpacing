import AppKit
import Foundation

enum MenuBarRestart {

    /// Reboot the Mac. Spacing changes always take effect after reboot.
    static func reboot() {
        let source = """
            tell application "System Events" to restart
            """
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
    }

    /// Log the user out. Spacing changes take effect on next login.
    static func logout() {
        let source = """
            tell application "loginwindow" to \u{00AB}event aevtlogo\u{00BB}
            """
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
    }
}

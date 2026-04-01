import Cocoa
import SwiftUI

public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController(window: NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 520),
        styleMask: [.titled, .closable, .miniaturizable],
        backing: .buffered, defer: false
    ))
    
    private override init(window: NSWindow?) {
        super.init(window: window)
        window?.title = "PeekBoard Settings"
        window?.center()
        window?.isReleasedWhenClosed = false
        window?.contentView = NSHostingView(rootView: SettingsView())
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public func show() {
        if let window = window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
    }
}

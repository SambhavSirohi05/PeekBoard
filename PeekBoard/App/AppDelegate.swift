import Cocoa
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var hotKey: HotKey?
    
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Force hide the Dock icon explicitly (in case Info.plist was overridden by Xcode)
        NSApp.setActivationPolicy(.accessory)
        
        let _ = EyeIconManager.shared
        let _ = DatabaseManager.shared
        
        ClipboardMonitor.shared.start()
        PanelController.shared.setup()
        
        setupHotKey()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("OpenSettings"), object: nil, queue: nil) { _ in
            SettingsWindowController.shared.show()
        }
        
        showFirstLaunchAlertIfNeeded()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        ClipboardMonitor.shared.stop()
    }
    
    private func setupHotKey() {
        hotKey = HotKey(key: .v, modifiers: [.option])
        hotKey?.keyDownHandler = {
            PanelController.shared.toggle()
        }
    }
    
    private func showFirstLaunchAlertIfNeeded() {
        let key = UserDefaultsKeys.hasCompletedOnboarding
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = NSAlert()
            alert.messageText = "One thing before you start"
            alert.informativeText = "PeekBoard needs Accessibility access to paste items directly into your apps. Open System Settings → Privacy & Security → Accessibility and add PeekBoard.\n\nYou can still use PeekBoard without it — items will be copied to your clipboard and you press ⌘V yourself."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")
            
            NSApp.activate(ignoringOtherApps: true)
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                AccessibilityChecker.shared.openAccessibilitySettings()
            }
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}

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
}

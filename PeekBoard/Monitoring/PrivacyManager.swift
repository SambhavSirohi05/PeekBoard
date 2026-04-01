import Cocoa

public final class PrivacyManager {
    public static let shared = PrivacyManager()
    
    private init() {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: nil) { [weak self] _ in
            self?.handleScreenLock()
        }
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.sessionDidResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.handleScreenLock()
        }
    }
    
    public func setup() {
        // Init triggers observer registration
    }
    
    private func handleScreenLock() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.autoPauseOnLock) {
            ClipboardMonitor.shared.setPaused(true)
        }
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.autoClearOnLock) {
            try? DatabaseManager.shared.clearUnpinnedHistory()
        }
    }
}

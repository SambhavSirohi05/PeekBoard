import Cocoa
import Combine

public final class AccessibilityChecker: ObservableObject {
    public static let shared = AccessibilityChecker()
    
    @Published public var isTrusted = false
    private var timer: Timer?
    
    private init() {
        check()
    }
    
    public func startPolling() {
        if isTrusted { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.check()
            if self?.isTrusted == true {
                self?.timer?.invalidate()
            }
        }
    }
    
    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    @discardableResult
    public func check() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        if isTrusted != trusted {
            DispatchQueue.main.async {
                self.isTrusted = trusted
            }
        }
        return trusted
    }
    
    public func promptForAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    public func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

import Cocoa

public final class PasteEngine {
    public static let shared = PasteEngine()
    
    private init() {}
    
    public func paste(entry: ClipboardEntry, asPlainText: Bool) {
        let board = NSPasteboard.general
        board.clearContents()
        
        if asPlainText, let text = entry.contentText {
            board.setString(text, forType: .string)
        } else {
            if let text = entry.contentText {
                board.setString(text, forType: .string)
            } else if let imgData = entry.imageThumbnailData {
                board.setData(imgData, forType: .png)
            }
        }
        
        ClipboardMonitor.shared.ignoreNextChange()
        
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        if !entry.isPinned {
            var updated = entry
            updated.createdAt = Date().timeIntervalSince1970
            do {
                try DatabaseManager.shared.insertOrUpdate(&updated)
                NotificationCenter.default.post(name: NSNotification.Name("ClipboardEntryUpdated"), object: updated)
            } catch {}
        }
        
        // PanelController.shared.close() // App no longer closes on "copy"/paste
        
        if AccessibilityChecker.shared.check() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.synthesizeCmdV()
            }
        }
    }
    
    public func copyToClipboard(entry: ClipboardEntry) {
        let board = NSPasteboard.general
        board.clearContents()
        
        if let text = entry.contentText {
            board.setString(text, forType: .string)
        } else if let imgData = entry.imageThumbnailData {
            board.setData(imgData, forType: .png)
        }
        
        ClipboardMonitor.shared.ignoreNextChange()
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        if !entry.isPinned {
            var updated = entry
            updated.createdAt = Date().timeIntervalSince1970
            do {
                try DatabaseManager.shared.insertOrUpdate(&updated)
                NotificationCenter.default.post(name: NSNotification.Name("ClipboardEntryUpdated"), object: updated)
            } catch {}
        }
    }
    
    private func synthesizeCmdV() {
        let vKeyCode: CGKeyCode = 0x09
        let source = CGEventSource(stateID: .hidSystemState)
        
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        keyDown?.flags = .maskCommand
        
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
        keyUp?.flags = .maskCommand
        
        keyDown?.post(tap: .cgSessionEventTap)
        keyUp?.post(tap: .cgSessionEventTap)
    }
}

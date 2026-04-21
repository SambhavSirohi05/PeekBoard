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
        
        // Auto-pasting disabled by user request
        // PanelController.shared.close() is currently commented out, so it stays open
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
    
}

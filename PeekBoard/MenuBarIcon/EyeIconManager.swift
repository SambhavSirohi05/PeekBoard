import Cocoa

public final class EyeIconManager {
    public static let shared = EyeIconManager()
    
    public let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private let imgIdle = NSImage(named: "eye-closed")
    private let imgHalf = NSImage(named: "eye-half")
    private let imgOpen = NSImage(named: "eye-open")
    private let imgPaused = NSImage(named: "eye-paused")
    
    private var blinkTimer: Timer?
    
    public var isPaused: Bool = false {
        didSet {
            updateIcon()
        }
    }
    
    public var isPanelOpen: Bool = false {
        didSet {
            updateIcon()
        }
    }
    
    private init() {
        imgIdle?.isTemplate = true
        imgHalf?.isTemplate = true
        imgOpen?.isTemplate = true
        imgPaused?.isTemplate = true
        if let button = statusItem.button {
            button.image = imgIdle
            button.target = self
            button.action = #selector(iconClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NewClipboardEntry"), object: nil, queue: nil) { [weak self] _ in
            self?.blink()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("MonitoringPausedStateChanged"), object: nil, queue: nil) { [weak self] notification in
            if let isPaused = notification.object as? Bool {
                self?.isPaused = isPaused
            }
        }
    }
    
    @objc private func iconClicked() {
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            isPaused.toggle()
        } else {
            PanelController.shared.toggle()
        }
    }
    
    public func updateIcon() {
        guard let button = statusItem.button else { return }
        if isPaused {
            button.image = imgPaused
        } else if isPanelOpen {
            button.image = imgOpen
        } else {
            button.image = imgIdle
        }
    }
    
    public func blink() {
        guard !isPaused && !isPanelOpen else { return }
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        
        let frames = [imgHalf, imgOpen, imgIdle]
        var frameIndex = 0
        
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, let button = self.statusItem.button else {
                timer.invalidate()
                return
            }
            
            button.image = frames[frameIndex]
            frameIndex += 1
            
            if frameIndex >= frames.count {
                timer.invalidate()
                self.updateIcon()
            }
        }
    }
}

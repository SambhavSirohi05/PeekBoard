import Cocoa
import SwiftUI

public class PeekPanel: NSPanel {
    public override var canBecomeKey: Bool { return true }
}

public final class PanelController: NSObject, NSWindowDelegate {
    public static let shared = PanelController()
    public var isSearchActive: Bool = false
    
    public var panel: NSPanel!
    private var hostingView: NSHostingView<PanelView>!
    private var visualEffectView: NSVisualEffectView!
    
    private override init() {
        super.init()
    }
    
    public func setup() {
        panel = PeekPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 520),
                        styleMask: [.borderless, .nonactivatingPanel],
                        backing: .buffered,
                        defer: false)
        
        panel.level = .statusBar + 1
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.delegate = self
        
        visualEffectView = NSVisualEffectView()
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 14
        let isDark = NSApp.effectiveAppearance.name == .darkAqua || NSApp.effectiveAppearance.name == .vibrantDark
        visualEffectView.layer?.borderWidth = 0.5
        visualEffectView.layer?.borderColor = isDark ? NSColor(white: 1.0, alpha: 0.12).cgColor : NSColor(white: 0.0, alpha: 0.08).cgColor
        
        hostingView = NSHostingView(rootView: PanelView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        visualEffectView.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor)
        ])
        
        panel.contentView = visualEffectView
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if self?.panel.isVisible == true {
                self?.close()
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.panel.isVisible else { return event }
            
            // If another window in our app is key (e.g. standard Alert), don't intercept keys!
            if NSApp.keyWindow != nil && NSApp.keyWindow != self.panel {
                return event
            }
            
            if event.keyCode == 53 { // Escape
                NotificationCenter.default.post(name: NSNotification.Name("EscapePressed"), object: nil)
                return nil
            }
            
            if self.isSearchActive {
                if event.keyCode == 125 { // Down arrow
                    NotificationCenter.default.post(name: NSNotification.Name("MoveSelection"), object: 1)
                    return nil
                }
                if event.keyCode == 126 { // Up arrow
                    NotificationCenter.default.post(name: NSNotification.Name("MoveSelection"), object: -1)
                    return nil
                }
                if event.keyCode == 36 { // Return
                    NotificationCenter.default.post(name: NSNotification.Name("PasteSelected"), object: event.modifierFlags.contains(.command))
                    return nil
                }
                // Do not intercept other keys (e.g., Backspace) when searching
                return event
            }
            
            if event.keyCode == 125 { // Down arrow
                NotificationCenter.default.post(name: NSNotification.Name("MoveSelection"), object: 1)
                return nil
            }
            if event.keyCode == 126 { // Up arrow
                NotificationCenter.default.post(name: NSNotification.Name("MoveSelection"), object: -1)
                return nil
            }
            if event.keyCode == 36 { // Return
                NotificationCenter.default.post(name: NSNotification.Name("PasteSelected"), object: event.modifierFlags.contains(.command))
                return nil
            }
            if event.keyCode == 2 { // 'd' -> ⌘D
                if event.modifierFlags.contains(.command) {
                    NotificationCenter.default.post(name: NSNotification.Name("TogglePinSelected"), object: nil)
                    return nil
                }
            }
            if event.keyCode == 51 { // Delete
                NotificationCenter.default.post(name: NSNotification.Name("DeleteSelected"), object: nil)
                return nil
            }
            if event.keyCode == 8 { // 'c' -> ⌘C
                if event.modifierFlags.contains(.command) {
                    NotificationCenter.default.post(name: NSNotification.Name("CopySelected"), object: nil)
                    return nil
                }
            }
            
            // Cmd+1..9
            if event.modifierFlags.contains(.command) {
                let chars = event.charactersIgnoringModifiers ?? ""
                if let num = Int(chars), num >= 1, num <= 9 {
                    NotificationCenter.default.post(name: NSNotification.Name("PasteNumbered"), object: num)
                    return nil
                }
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("PanelKeyDown"), object: event)
            return event
        }
    }
    
    public func toggle() {
        if panel.isVisible {
            close()
        } else {
            open()
        }
    }
    
    public func open() {
        positionPanel()
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        if reduceMotion {
            panel.alphaValue = 1.0
            panel.makeKeyAndOrderFront(nil)
            EyeIconManager.shared.isPanelOpen = true
        } else {
            panel.alphaValue = 0.0
            panel.makeKeyAndOrderFront(nil)
            EyeIconManager.shared.isPanelOpen = true
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.18
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.panel.animator().alphaValue = 1.0
            }
        }
        panel.makeFirstResponder(nil) // Reset focus
    }
    
    public func close() {
        if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            self.panel.orderOut(nil)
            EyeIconManager.shared.isPanelOpen = false
            self.panel.alphaValue = 0.0
        } else {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self.panel.animator().alphaValue = 0.0
            }) {
                self.panel.orderOut(nil)
                EyeIconManager.shared.isPanelOpen = false
            }
        }
    }
    
    private func positionPanel() {
        guard let button = EyeIconManager.shared.statusItem.button,
              let window = button.window,
              let screen = window.screen else { return }
        
        let buttonFrame = button.convert(button.bounds, to: nil)
        let buttonRectOnScreen = window.convertToScreen(buttonFrame)
        let panelWidth: CGFloat = 340
        var x = buttonRectOnScreen.midX - (panelWidth / 2)
        
        let screenRect = screen.visibleFrame
        if x < screenRect.minX + 180 {
            x = buttonRectOnScreen.minX
        } else if x + panelWidth > screenRect.maxX - 180 {
            x = buttonRectOnScreen.maxX - panelWidth
        }
        
        x = max(screenRect.minX, min(x, screenRect.maxX - panelWidth))
        let y = buttonRectOnScreen.minY - panel.frame.height - 4
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    public func windowDidResignKey(_ notification: Notification) {
        if NSApp.keyWindow != nil && NSApp.keyWindow != panel {
            // Another window in our app (like the rename alert) took focus
            return
        }
        if panel.isVisible { close() }
    }
}

import Cocoa

public final class ClipboardMonitor {
    public static let shared = ClipboardMonitor()
    
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var lastCaptureTime: TimeInterval = 0
    private var isPaused = false
    
    private var lastCapturedText: String?
    private var lastCapturedImageData: Data?
    
    private let passwordManagers = [
        "com.1password.1password",
        "com.agilebits.onepassword-mac",
        "com.bitwarden.desktop",
        "in.sinew.Enpass-Desktop",
        "com.apple.keychainaccess"
    ]
    
    private init() {}
    
    public func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    public func setPaused(_ paused: Bool) {
        if paused {
            stop()
        } else {
            start()
        }
        isPaused = paused
        NotificationCenter.default.post(name: NSNotification.Name("MonitoringPausedStateChanged"), object: isPaused)
    }
    
    public func ignoreNextChange() {
        lastChangeCount = NSPasteboard.general.changeCount
    }
    
    private func checkForChanges() {
        guard !isPaused else { return }
        
        let board = NSPasteboard.general
        guard board.changeCount != lastChangeCount else { return }
        lastChangeCount = board.changeCount
        
        let now = Date().timeIntervalSince1970
        guard (now - lastCaptureTime) > 0.1 else { return }
        
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let bundleIdentifier = frontmostApp.bundleIdentifier else { return }
        
        if passwordManagers.contains(bundleIdentifier) { return }
        
        if let excluded = UserDefaults.standard.array(forKey: "ExcludedApps") as? [String],
           excluded.contains(bundleIdentifier) {
            return
        }
        
        var parsedText: String?
        var parsedImage: Data?
        var parsedType: ContentType = .text
        
        if let text = board.string(forType: .string) {
            if text == lastCapturedText {
                handleIdenticalCopy(text: text)
                return
            }
            parsedText = text
            parsedType = ContentType.detect(from: text)
        } else if let imgData = board.data(forType: .png) ?? board.data(forType: .tiff) {
            if imgData == lastCapturedImageData {
                return
            }
            if imgData.count > 25 * 1024 * 1024 { return }
            
            if let image = NSImage(data: imgData) {
                parsedImage = createThumbnail(from: image)
                parsedType = .image
            }
        } else if let fileURLStr = board.string(forType: .fileURL), let url = URL(string: fileURLStr) {
            let path = url.path
            if path == lastCapturedText {
                handleIdenticalCopy(text: path)
                return
            }
            parsedText = path
            parsedType = .text
        }
        
        guard parsedText != nil || parsedImage != nil else { return }
        
        lastCapturedText = parsedText
        lastCapturedImageData = parsedImage
        lastCaptureTime = now
        
        var entry = ClipboardEntry(
            contentText: parsedText,
            contentType: parsedType.rawValue,
            imageThumbnailData: parsedImage,
            sourceAppBundleId: bundleIdentifier,
            sourceAppName: frontmostApp.localizedName
        )
        
        do {
            try DatabaseManager.shared.insertOrUpdate(&entry)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("NewClipboardEntry"), object: entry)
            }
        } catch {
            print("Failed to save entry: \\(error)")
        }
    }
    
    private func handleIdenticalCopy(text: String) {
        lastCaptureTime = Date().timeIntervalSince1970
        do {
            let entries = try DatabaseManager.shared.fetchRecent()
            if let index = entries.firstIndex(where: { $0.contentText == text }) {
                var entry = entries[index]
                entry.createdAt = Date().timeIntervalSince1970
                try DatabaseManager.shared.insertOrUpdate(&entry)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("ClipboardEntryUpdated"), object: entry)
                }
            }
        } catch {
            print("Failed handling identical copy: \\(error)")
        }
    }
    
    private func createThumbnail(from image: NSImage) -> Data? {
        let maxDim: CGFloat = 400.0
        var size = image.size
        if size.width > maxDim || size.height > maxDim {
            let ratio = min(maxDim / size.width, maxDim / size.height)
            size = CGSize(width: size.width * ratio, height: size.height * ratio)
        }
        
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size), from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        
        if let tiff = newImage.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
            var compression: CGFloat = 0.8
            var jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: compression])
            
            while let data = jpegData, data.count > 200_000, compression > 0.1 {
                compression -= 0.1
                jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: compression])
            }
            return jpegData
        }
        
        return nil
    }
}

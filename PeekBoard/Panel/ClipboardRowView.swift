import SwiftUI

struct ClipboardRowView: View {
    let entry: ClipboardEntry
    let indexItem: Int?
    let onPaste: (Bool) -> Void
    let onPinToggle: () -> Void
    let onDelete: () -> Void
    let onDeleteAllOfType: () -> Void
    
    @Binding var selectedEntryId: Int64?
    
    @AppStorage(UserDefaultsKeys.panelDensity) var panelDensity: String = "Normal"
    
    @State private var isHovered = false
    @State private var flashGreen = false
    
    var rowHeight: CGFloat {
        switch panelDensity {
        case "Compact": return 40
        case "Expanded": return 68
        default: return 52
        }
    }
    
    var isSelected: Bool {
        selectedEntryId == entry.id
    }
    
    var body: some View {
        HStack(spacing: 12) {
            badgeView
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.contentText ?? (entry.contentType == "image" ? "Image" : "Unknown"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    if entry.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    
                    if let appName = entry.sourceAppName {
                        Text("\(TimeAgoFormatter.string(from: entry.createdAt)) · \(entry.contentType) · \(appName)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("\(TimeAgoFormatter.string(from: entry.createdAt)) · \(entry.contentType)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            Spacer(minLength: 8)
            
            if isHovered || isSelected {
                HStack(spacing: 8) {
                    if let idx = indexItem, idx <= 9 {
                        Text("⌘\(idx)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    Menu {
                        Button(entry.isPinned ? "Unpin" : "Pin") { onPinToggle() }
                        Button("Copy without Pasting") { PasteEngine.shared.copyToClipboard(entry: entry) }
                        Divider()
                        Button("Delete", role: .destructive) { onDelete() }
                        Button("Delete All of This Type", role: .destructive) { onDeleteAllOfType() }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .frame(width: 20)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: rowHeight)
        .contentShape(Rectangle())
        .background(
            ZStack {
                if flashGreen {
                    Color.green.opacity(0.3)
                } else if isSelected {
                    Color.accentColor.opacity(0.2)
                } else if isHovered {
                    Color.primary.opacity(NSApp.effectiveAppearance.name == .darkAqua ? 0.05 : 0.04)
                } else {
                    Color.clear
                }
            }
        )
        .cornerRadius(6)
        .onHover { h in
            withAnimation(.easeInOut(duration: 0.08)) {
                isHovered = h
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                triggerPaste(plainText: false)
            }
        )
    }
    
    private func triggerPaste(plainText: Bool) {
        flashGreen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            flashGreen = false
            onPaste(plainText)
        }
    }
    
    @ViewBuilder
    private var badgeView: some View {
        Group {
            switch entry.contentType {
            case "text":
                Text("T").font(.system(size:14, weight:.medium)).foregroundColor(.blue).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.blue.opacity(0.2))
            case "url":
                Text("↗").font(.system(size:14, weight:.medium)).foregroundColor(.green).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.green.opacity(0.2))
            case "code":
                Text("{}").font(.system(size:14, design:.monospaced)).foregroundColor(.orange).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.orange.opacity(0.2))
            case "hex_color":
                if let hex = entry.contentText {
                    Circle().fill(Color(hex: hex) ?? .clear).padding(4)
                } else {
                    Color.clear
                }
            case "email":
                Text("@").font(.system(size:14, weight:.medium)).foregroundColor(.purple).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.purple.opacity(0.2))
            case "phone":
                Text("📞").font(.system(size:14)).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.teal.opacity(0.2))
            case "image":
                if let data = entry.imageThumbnailData, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage).resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            default:
                Text("T").font(.system(size:14, weight:.medium)).foregroundColor(.blue).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.blue.opacity(0.2))
            }
        }
        .cornerRadius(6)
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 3 {
            r = CGFloat((rgb & 0xF00) >> 8) / 15.0
            g = CGFloat((rgb & 0x0F0) >> 4) / 15.0
            b = CGFloat(rgb & 0x00F) / 15.0
        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
